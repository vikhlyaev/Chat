import Foundation
import CoreData
import TFSChatTransport
import Combine
import OSLog

protocol DataSourceDelegate: AnyObject {
    func didUpdateChannels(with channels: [ChannelModel])
    func didUpdateMessages(with messages: [MessageModel])
    func didShowAlert(alert: UIAlertController)
}

protocol DataSourceProtocol {
    var delegate: DataSourceDelegate? { get set }
    func indexLastCellInSection(section: Int) -> Int
    func createChannel(with name: String, and logoUrl: String?)
    func deleteChannel(with channelName: ChannelModel)
}

final class DataSource {
    
    weak var delegate: DataSourceDelegate?
    
    // MARK: - Helpers
    
    private var logger: Logger {
        if ProcessInfo.processInfo.environment.keys.contains("DATASOURCE_LOG") {
            return Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "DataSourceLog")
        } else {
            return Logger(.disabled)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - CoreData
    
    private lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Chat")
        container.loadPersistentStores { [weak self] _, error in
            if let error = error as NSError? {
                self?.logger.error("🔴 Failed to create persistant container")
                fatalError()
            }
        }
        return container
    }()
    
    private lazy var viewContext: NSManagedObjectContext = {
        persistantContainer.viewContext
    }()
    
    private var fetchResultController: NSFetchedResultsController<NSFetchRequestResult>?
    
    // MARK: - Services
    
    private let chatService = ChatService()
    
    // MARK: - Init
    
    init(entityName: String, sortName: String, delegate: DataSourceDelegate) {
        self.delegate = delegate
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortName, ascending: false)]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext: viewContext,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
        
        setDelegates()
        performFetch()
        loadChannelsFromNetwork()
    }
    
    private func setDelegates() {
        if let delegate = delegate as? NSFetchedResultsControllerDelegate {
            fetchResultController?.delegate = delegate
        }
    }
    
    // MARK: - CoreData methods
    
    private func performFetch() {
        do {
            try fetchResultController?.performFetch()
            logger.info("🟢 Performing the fetch is complete")
        } catch {
            logger.error("🔴 Performing the fetch has not been completed")
        }
    }
    
    private func deleteChannelModelFromStorage(with channelModel: ChannelModel) {
        save { context in
            let fetchRequest = ChannelManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", channelModel.id as CVarArg)
            do {
                fetchResultController?.fetchRequest.predicate = NSPredicate(format: "id == %@", channelModel.id as CVarArg)
                guard let channelManagedObject = try context.fetch(fetchRequest).first else { return }
                context.delete(channelManagedObject)
                logger.info("🟢 Channel deleted")
                logger.info("💭 Main thread: \(Thread.isMainThread)")
            } catch {
                logger.error("🔴 Channel has not been deleted")
            }
        }
    }
    
    private func saveChannelInStorage(with channelModel: ChannelModel) {
        save { context in
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
    
    private func save(block: (NSManagedObjectContext) throws -> Void) {
        let backgroundContext = persistantContainer.newBackgroundContext()
        backgroundContext.performAndWait {
            do {
                try block(backgroundContext)
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }
            } catch {
                logger.error("🔴 Saving error: \(error)")
            }
        }
    }
    
    // MARK: - ChatService methods
    
    private func createChannelInNetwork(name: String, logoUrl: String?) {
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
                        guard let self else { return }
                        self.createChannelInNetwork(name: name, logoUrl: logoUrl)
                    }
                    alert.addAction(okAction)
                    alert.addAction(tryAgainAction)
                    DispatchQueue.main.async { [weak self] in
                        self?.delegate?.didShowAlert(alert: alert)
                    }
                }
            } receiveValue: { [weak self] newChannel in
                guard let self else { return }
                let model = self.convert(channel: newChannel)
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didUpdateChannels(with: [model])
                }
                self.saveChannelInStorage(with: model)
                self.logger.info("🟢 Channel is created and stored in storage")
            }
            .store(in: &cancellables)
    }
    
    private func loadChannelsFromNetwork() {
        chatService.loadChannels()
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.logger.info("🟢 Channels loaded")
                case .failure:
                    let alert = UIAlertController(title: "Error", message: "Could not load channels", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { [weak self] _ in
                        self?.loadChannelsFromNetwork()
                    }
                    alert.addAction(okAction)
                    alert.addAction(tryAgainAction)
                    DispatchQueue.main.async { [weak self] in
                        self?.delegate?.didShowAlert(alert: alert)
                    }
                }
            } receiveValue: { [weak self] channels in
                guard let self else { return }
                channels.forEach { channel in
                    let model = self.convert(channel: channel)
                    self.saveChannelInStorage(with: model)
                    self.logger.info("🟢 Channel is loaded and stored in storage")
                }
            }
            .store(in: &cancellables)
    }
    
    private func deleteChannelFromNetwork(with channelModel: ChannelModel) {
        chatService.deleteChannel(id: channelModel.id)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.logger.info("🟢 Channel deleted")
                case .failure:
                    let alert = UIAlertController(title: "Error", message: "Unable to delete channel", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okAction)
                    DispatchQueue.main.async { [weak self] in
                        self?.delegate?.didShowAlert(alert: alert)
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
    
    private func convert(channelManagedObject: ChannelManagedObject) -> ChannelModel {
        ChannelModel(id: channelManagedObject.id ?? "",
                     name: channelManagedObject.name ?? "",
                     logoURL: channelManagedObject.logoURL,
                     lastMessage: channelManagedObject.lastMessage,
                     lastActivity: channelManagedObject.lastActivity)
    }
    
    //    private func fetchMessages(for channelId: String) throws -> [MessageManagedObject] {
    //        let fetchRequest = ChannelManagedObject.fetchRequest()
    //        fetchRequest.predicate = NSPredicate(format: "id == %@", channelId as CVarArg)
    //        guard
    //            let channelManagedObject = try viewContext.fetch(fetchRequest).first,
    //            let messagesManagedObjects = channelManagedObject.messages?.array as? [MessageManagedObject]
    //        else {
    //            return []
    //        }
    //        return messagesManagedObjects
    //    }
    
    //    private func getMessagesFromStorage(for channelId: String) -> [MessageModel] {
    //        do {
    //            let messageManagedObjects = try fetchMessages(for: channelId)
    //            let messages: [MessageModel] = messageManagedObjects.compactMap { messageManagedObject in
    //                guard
    //                    let id = messageManagedObject.id,
    //                    let text = messageManagedObject.text,
    //                    let userId = messageManagedObject.userID,
    //                    let userName = messageManagedObject.userName,
    //                    let date = messageManagedObject.date
    //                else {
    //                    return nil
    //                }
    //                return MessageModel(id: id,
    //                                    text: text,
    //                                    userID: userId,
    //                                    userName: userName,
    //                                    date: date)
    //            }
    //            return messages
    //        } catch {
    //            print(error)
    //            return []
    //        }
    
    //    private func saveMessageModelInStorage(with messageModel: MessageModel, in channelModel: ChannelModel) {
    //        save { context in
    //            let fetchRequest = ChannelManagedObject.fetchRequest()
    //            fetchRequest.predicate = NSPredicate(format: "id == %@", channelModel.id as CVarArg)
    //            let channelManagedObject = try context.fetch(fetchRequest).first
    //
    //            guard let channelManagedObject else { return }
    //
    //            let messageManagedObject = MessageManagedObject(context: context)
    //            messageManagedObject.id = messageModel.id
    //            messageManagedObject.text = messageModel.text
    //            messageManagedObject.userID = messageModel.userID
    //            messageManagedObject.userName = messageModel.userName
    //            messageManagedObject.date = messageModel.date
    //
    //            channelManagedObject.addToMessages(messageManagedObject)
    //        }
    //    }
}

// MARK: - DataSourceProtocol

extension DataSource: DataSourceProtocol {
    func indexLastCellInSection(section: Int) -> Int {
        guard let sections = fetchResultController?.sections else { fatalError("No sections in fetchedResultsController") }
        return sections[section].numberOfObjects == 0 ? 0 : sections[section].numberOfObjects - 1
    }
    
    func createChannel(with name: String, and logoUrl: String?) {
        createChannelInNetwork(name: name, logoUrl: logoUrl)
    }
    
    func deleteChannel(with channelName: ChannelModel) {
        deleteChannelFromNetwork(with: channelName)
        deleteChannelModelFromStorage(with: channelName)
    }
}
