import Foundation
import CoreData
import TFSChatTransport
import Combine
import OSLog

protocol DataSourceDelegate: AnyObject {
    func didShowAlert(alert: UIAlertController)
}

protocol DataSourceProtocol {
    var channelsPublisher: CurrentValueSubject<[ChannelModel], Never> { get }
    var messagesPublisher: CurrentValueSubject<[MessageModel], Never> { get }
    func loadChannelsFromNetwork()
    func createChannelInNetwork(name: String, logoUrl: String?)
    func deleteChannelFromNetwork(with channelModel: ChannelModel)
    func deleteChannelFromStorage(with channelModel: ChannelModel)
    func getMessages(for channelId: String)
    func sendMessage(text: String, channelId: String, userId: String, userName: String)
}

final class DataSource: DataSourceProtocol {
    
    weak var delegate: DataSourceDelegate?
    
    // MARK: - Data Source
    
    private var channels: [ChannelModel] = []
    private var messages: [MessageModel] = []
    
    // MARK: - Helpers
    
    private var logger: Logger {
        if ProcessInfo.processInfo.environment.keys.contains("DATASOURCE_LOG") {
            return Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "DataSourceLog")
        } else {
            return Logger(.disabled)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Services
    
    private let chatService = ChatService()
    private let coreDataService: CoreDataService = ServiceAssembly.shared.coreDataService
    
    // MARK: - Publishers
    
    lazy var channelsPublisher = CurrentValueSubject<[ChannelModel], Never>(channels)
    lazy var messagesPublisher = CurrentValueSubject<[MessageModel], Never>(messages)
    
    // MARK: - Init
    
    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
        updateChannelsFromStorage()
        loadChannelsFromNetwork()
    }
    
    func getMessages(for channelId: String) {
        updateMessagesFromStorage(for: channelId)
        loadMessagesFromNetwork(for: channelId)
    }
    
    // MARK: - Storage
    
    private func updateChannelsFromStorage() {
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
                return ChannelModel(id: id,
                                    name: name,
                                    logoUrl: logoURL,
                                    lastMessage: lastMessage,
                                    lastActivity: lastActivity)
            }
            logger.info("🟢 Channels received")
            self.channels = channels
            self.channelsPublisher.send(self.channels)
        } catch {
            logger.error("🔴 Channels not received")
            fatalError()
        }
    }
    
    private func saveChannelInStorage(with channelModel: ChannelModel) {
        coreDataService.update { context in
            let fetchRequest = ChannelManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", channelModel.id as CVarArg)
            let channelManagedObject = try context.fetch(fetchRequest).first
            
            if let channelManagedObject = channelManagedObject {
                channelManagedObject.lastMessage = channelModel.lastMessage
                channelManagedObject.lastActivity = channelModel.lastActivity
                logger.info("🟡 Channel updated")
            } else {
                let channelManagedObject = ChannelManagedObject(context: context)
                channelManagedObject.id = channelModel.id
                channelManagedObject.name = channelModel.name
                channelManagedObject.logoURL = channelModel.logoUrl
                channelManagedObject.lastMessage = channelModel.lastMessage
                channelManagedObject.lastActivity = channelModel.lastActivity
                channelManagedObject.messages = NSOrderedSet()
                logger.info("🟢 Channel added")
            }
        }
    }
    
    func deleteChannelFromStorage(with channelModel: ChannelModel) {
        coreDataService.update { context in
            let fetchRequest = ChannelManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", channelModel.id as CVarArg)
            guard
                let channelManagedObject = try context.fetch(fetchRequest).first
            else {
                logger.error("🔴 Channel has not been deleted")
                fatalError()
            }
            context.delete(channelManagedObject)
            logger.info("🟢 Channel deleted")
        }
    }
    
    private func updateMessagesFromStorage(for channelId: String) {
        messages = []
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
            logger.info("🟢 Messages received")
            self.messages = messages
            self.messagesPublisher.send(self.messages)
        } catch {
            logger.error("🔴 Messages not received")
            fatalError()
        }
    }
    
    private func saveMessageModelInStorage(with messageModel: MessageModel, in channelId: String) {
        coreDataService.update { context in
            let fetchRequest = ChannelManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", channelId as CVarArg)
            guard
                let channelManagedObject = try context.fetch(fetchRequest).first,
                let messageManagedObjects = channelManagedObject.messages?.array as? [MessageManagedObject]
            else { return }
            let checkingForDuplicates = messageManagedObjects.contains { messageManagedObject in
                messageManagedObject.date == messageModel.date
            }
            if !checkingForDuplicates {
                let messageManagedObject = MessageManagedObject(context: context)
                messageManagedObject.id = messageModel.id
                messageManagedObject.text = messageModel.text
                messageManagedObject.userID = messageModel.userID
                messageManagedObject.userName = messageModel.userName
                messageManagedObject.date = messageModel.date
                channelManagedObject.addToMessages(messageManagedObject)
                logger.info("🟢 Messages added")
            }
        }
    }
    
    // MARK: - Network
    
    func loadChannelsFromNetwork() {
        chatService.loadChannels()
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] _ in
                self?.updateChannelsFromStorage()
            } receiveValue: { [weak self] channels in
                guard let self else { return }
                channels.forEach { channel in
                    let model = self.convert(channel: channel)
                    self.saveChannelInStorage(with: model)
                    self.logger.info("🟢 Channel loaded")
                }
            }
            .store(in: &cancellables)
    }
    
    func createChannelInNetwork(name: String, logoUrl: String?) {
        chatService.createChannel(name: name, logoUrl: logoUrl)
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.global(qos: .utility))
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    self.updateChannelsFromStorage()
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
                self.saveChannelInStorage(with: model)
                self.logger.info("🟢 Channel created")
            }
            .store(in: &cancellables)
    }
    
    func deleteChannelFromNetwork(with channelModel: ChannelModel) {
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
    
    private func loadMessagesFromNetwork(for channelId: String) {
        chatService.loadMessages(channelId: channelId)
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] _ in
                self?.updateMessagesFromStorage(for: channelId)
            } receiveValue: { [weak self] messages in
                guard let self else { return }
                messages.forEach { message in
                    let model = self.convert(message: message)
                    self.saveMessageModelInStorage(with: model, in: channelId)
                    self.logger.info("🟢 Message loaded")
                }
            }
            .store(in: &cancellables)
    }
    
    func sendMessage(text: String, channelId: String, userId: String, userName: String) {
        chatService.sendMessage(text: text, channelId: channelId, userId: userId, userName: userName)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    self.updateMessagesFromStorage(for: channelId)
                    print(self.channels)
                case .failure:
                    let alert = UIAlertController(title: "Error", message: "Unable to send message", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { [weak self] _ in
                        self?.sendMessage(text: text, channelId: channelId, userId: userId, userName: userName)
                    }
                    alert.addAction(okAction)
                    alert.addAction(tryAgainAction)
                    DispatchQueue.main.async { [weak self] in
                        self?.delegate?.didShowAlert(alert: alert)
                    }
                }
            } receiveValue: { [weak self] newMessage in
                guard let self else { return }
                let message = self.convert(message: newMessage)
                self.saveMessageModelInStorage(with: message, in: channelId)
            }
            .store(in: &cancellables)
    }

    // MARK: - Helpers methods
    
    private func convert(channel: Channel) -> ChannelModel {
        ChannelModel(id: channel.id,
                     name: channel.name,
                     logoUrl: channel.logoURL,
                     lastMessage: channel.lastMessage,
                     lastActivity: channel.lastActivity)
    }
    
    private func convert(channelManagedObject: ChannelManagedObject) -> ChannelModel {
        ChannelModel(id: channelManagedObject.id ?? "",
                     name: channelManagedObject.name ?? "",
                     logoUrl: channelManagedObject.logoURL,
                     lastMessage: channelManagedObject.lastMessage,
                     lastActivity: channelManagedObject.lastActivity)
    }
    
    private func convert(message: Message) -> MessageModel {
        MessageModel(id: message.userID,
                     text: message.text,
                     userID: message.userID,
                     userName: message.userName,
                     date: message.date)
    }
}
