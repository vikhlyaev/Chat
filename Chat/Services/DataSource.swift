import Foundation
import CoreData
import TFSChatTransport
import Combine
import OSLog

protocol DataSourceProtocol {
    func indexLastCellInSection(section: Int) -> Int
    func getChannel(with indexPath: IndexPath) -> ChannelModel?
    func getNumberOfRows(section: Int) -> Int
    func createChannel(name: String, logoUrl: String?)
    func deleteChannel(with channelModel: ChannelModel)
}

final class DataSource: NSObject {
    
    private var logger: Logger {
        if ProcessInfo.processInfo.environment.keys.contains("COREDATA_LOGGING") {
            return Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "CoreDataLog")
        } else {
            return Logger(.disabled)
        }
    }
    
    private let coreDataService: CoreDataServiceProtocol = CoreDataService()
    private let chatService = ChatService()
    private var cancellables = Set<AnyCancellable>()
    var fetchResultController: NSFetchedResultsController<NSFetchRequestResult>?
 
    private weak var viewController: UIViewController?
    
    private var messages: [MessageModel]?
    
    init(viewController: UIViewController, entityName: String, sortName: String) {
        self.viewController = viewController
        fetchResultController = coreDataService.fetchResultController(entityName: entityName, sortName: sortName)
        
        super.init()
        setDelegates()
        performFetch()
        loadChannelsFromNetwork()
    }
    
    private func setDelegates() {
        guard
            let viewController = viewController as? NSFetchedResultsControllerDelegate,
            let fetchResultController = fetchResultController
        else { return }
        fetchResultController.delegate = viewController
    }
    
    // MARK: - CoreData Service methods
    
    private func performFetch() {
        do {
            try fetchResultController?.performFetch()
        } catch {
            print(error)
        }
    }
    
    private func getChannelsFromStorage() -> [ChannelModel] {
        do {
            let channelManagedObjects = try coreDataService.fetchChannels()
            let channels: [ChannelModel] = channelManagedObjects.compactMap { channelManagerObject in
                guard
                    let id = channelManagerObject.id,
                    let name = channelManagerObject.name
                else {
                    return nil
                }
                let logoURL = channelManagerObject.logoURL
                let lastMessage = channelManagerObject.lastMessage
                let lastActivity = channelManagerObject.lastActivity
                logger.info("\(String(describing: DataSource.self)): Successfully received - Main Thread: \(Thread.isMainThread)")
                return ChannelModel(id: id,
                                    name: name,
                                    logoURL: logoURL,
                                    lastMessage: lastMessage,
                                    lastActivity: lastActivity)
            }
            return channels
        } catch {
            logger.error("\(String(describing: DataSource.self)): Error receiving channels - Main Thread: \(Thread.isMainThread) - Error: \(error)")
            return []
        }
    }
    
    private func saveChannelModelInStorage(with channelModel: ChannelModel) {
        coreDataService.save { context in
            let fetchRequest = ChannelManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", channelModel.id as CVarArg)
            let channelManagedObject = try context.fetch(fetchRequest).first
            
            if let channelManagedObject = channelManagedObject {
                channelManagedObject.lastMessage = channelModel.lastMessage
                channelManagedObject.lastActivity = channelModel.lastActivity
            } else {
                let channelManagedObject = ChannelManagedObject(context: context)
                channelManagedObject.id = channelModel.id
                channelManagedObject.name = channelModel.name
                channelManagedObject.logoURL = channelModel.logoURL
                channelManagedObject.lastMessage = channelModel.lastMessage
                channelManagedObject.lastActivity = channelModel.lastActivity
                channelManagedObject.messages = NSOrderedSet()
            }
        }
    }
    
    private func deleteChannelModelFromStorage(with channelModel: ChannelModel) {
        coreDataService.save { context in
            let fetchRequest = ChannelManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", channelModel.id as CVarArg)
            do {
                guard let channelManagedObject = try context.fetch(fetchRequest).first else { return }
                context.delete(channelManagedObject)
            } catch {
                logger.error("\(String(describing: DataSource.self)): Delete channel error - Main Thread: \(Thread.isMainThread) - Error: \(error)")
            }
        }
    }
    
    private func getMessagesFromStorage(for channelId: String) -> [MessageModel] {
        do {
            let messageManagedObjects = try coreDataService.fetchMessages(for: channelId)
            let messages: [MessageModel] = messageManagedObjects.compactMap { messageManagedObject in
                guard
                    let id = messageManagedObject.id,
                    let text = messageManagedObject.text,
                    let userId = messageManagedObject.userID,
                    let userName = messageManagedObject.userName,
                    let date = messageManagedObject.date
                else {
                    return nil
                }
                return MessageModel(id: id,
                                    text: text,
                                    userID: userId,
                                    userName: userName,
                                    date: date)
            }
            return messages
        } catch {
            print(error)
            return []
        }
    }
    
    private func saveMessageModelInStorage(with messageModel: MessageModel, in channelModel: ChannelModel) {
        coreDataService.save { context in
            let fetchRequest = ChannelManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", channelModel.id as CVarArg)
            let channelManagedObject = try context.fetch(fetchRequest).first
            
            guard let channelManagedObject else { return }
            
            let messageManagedObject = MessageManagedObject(context: context)
            messageManagedObject.id = messageModel.id
            messageManagedObject.text = messageModel.text
            messageManagedObject.userID = messageModel.userID
            messageManagedObject.userName = messageModel.userName
            messageManagedObject.date = messageModel.date
            
            channelManagedObject.addToMessages(messageManagedObject)
        }
    }
    
    // MARK: - Combine methods
    
    private func loadChannelsFromNetwork() {
        chatService.loadChannels()
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("channels loaded")
                case .failure:
                    let alert = UIAlertController(title: "Error", message: "Could not load channels", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { [weak self] _ in
                        self?.loadChannelsFromNetwork()
                    }
                    alert.addAction(okAction)
                    alert.addAction(tryAgainAction)
                    DispatchQueue.main.async { [weak self] in
                        self?.viewController?.present(alert, animated: true)
                    }
                }
            } receiveValue: { [weak self] channels in
                guard let self else { return }
                channels.forEach { channel in
                    let channelModel = self.convert(channel: channel)
                    self.saveChannelModelInStorage(with: channelModel)
                }
            }
            .store(in: &cancellables)
    }
    
    private func createChannelOnNetwork(name: String, logoUrl: String? = nil) {
        chatService.createChannel(name: name, logoUrl: logoUrl)
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.global(qos: .utility))
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("channel created")
                case .failure:
                    let alert = UIAlertController(title: "Error", message: "Could not create a channel", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { [weak self] _ in
                        self?.createChannelOnNetwork(name: name)
                    }
                    alert.addAction(okAction)
                    alert.addAction(tryAgainAction)
                    DispatchQueue.main.async { [weak self] in
                        self?.viewController?.present(alert, animated: true)
                    }
                }
            } receiveValue: { [weak self] newChannel in
                guard let self else { return }
                let model = self.convert(channel: newChannel)
                self.saveChannelModelInStorage(with: model)
            }
            .store(in: &cancellables)
    }
    
    private func deleteChannelFromNetwork(with channelModel: ChannelModel) {
        chatService.deleteChannel(id: channelModel.id)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("channel deleted")
                case .failure:
                    let alert = UIAlertController(title: "Error", message: "Unable to delete channel", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okAction)
                    DispatchQueue.main.async { [weak self] in
                        self?.viewController?.present(alert, animated: true)
                    }
                }
            } receiveValue: {}
            .store(in: &cancellables)
    }
    
    // MARK: - Helpers methods
    
    private func convert(channel: Channel) -> ChannelModel {
        ChannelModel(id: channel.id,
                     name: channel.name,
                     logoURL: channel.logoURL,
                     lastMessage: channel.lastMessage,
                     lastActivity: channel.lastActivity)
    }
    
    private func convert(channels: [Channel]) -> [ChannelModel] {
        channels.map { convert(channel: $0) }
    }
}

// MARK: - DataSourceProtocol

extension DataSource: DataSourceProtocol {
    
    func indexLastCellInSection(section: Int) -> Int {
        guard let sections = fetchResultController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        return sections[section].numberOfObjects == 0 ? 0 : sections[section].numberOfObjects - 1
    }
    
    func getChannel(with indexPath: IndexPath) -> ChannelModel? {
        guard
            let channelManagedObject = fetchResultController?.object(at: indexPath) as? ChannelManagedObject
        else {
            return nil
        }
        return ChannelModel(id: channelManagedObject.id ?? "",
                            name: channelManagedObject.name ?? "",
                            logoURL: channelManagedObject.logoURL,
                            lastMessage: channelManagedObject.lastMessage,
                            lastActivity: channelManagedObject.lastActivity)
    }
    
    func getNumberOfRows(section: Int) -> Int {
        guard let sections = fetchResultController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func createChannel(name: String, logoUrl: String? = nil) {
        createChannelOnNetwork(name: name, logoUrl: logoUrl)
    }
    
    func deleteChannel(with channelModel: ChannelModel) {
        deleteChannelModelFromStorage(with: channelModel)
        deleteChannelFromNetwork(with: channelModel)
    }
    
}
