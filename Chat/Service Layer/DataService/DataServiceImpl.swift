import Foundation
import TFSChatTransport
import Combine

final class DataServiceImpl {
    
    // MARK: - Services
    
    private let coreDataService: CoreDataService
    private let chatTransportService: ChatTransportService
    private let sseTransportService: SSETransportService
    private let logService: LogService
    
    // MARK: - Storages
    
    private var messages: [MessageModel] = []
    private var channels: [ChannelModel] = []
    
    // MARK: - Publishers
    
    lazy var channelsPublisher = CurrentValueSubject<[ChannelModel], Never>(channels)
    lazy var messagesPublisher = CurrentValueSubject<[MessageModel], Never>(messages)
    
    private var cancellables = Set<AnyCancellable>()
    
    weak var delegate: DataServiceDelegate?
    
    // MARK: - Init
    
    init(coreDataService: CoreDataService,
         chatTransportService: ChatTransportService,
         sseTransportService: SSETransportService,
         logService: LogService) {
        self.coreDataService = coreDataService
        self.chatTransportService = chatTransportService
        self.sseTransportService = sseTransportService
        self.logService = logService
        
        loadChannelsFromNetwork()
        subscribeOnEvents()
    }
    
    // MARK: - SSE Service
    
    private func subscribeOnEvents() {
        sseTransportService.subscribeOnEvents()
            .receive(on: DispatchQueue.global(qos: .utility))
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] event in
                switch event.eventType {
                case .add:
                    self?.loadChannelFromNetwork(for: event.resourceID)
                case .update:
                    self?.loadChannelFromNetwork(for: event.resourceID)
                    self?.loadMessagesFromNetwork(for: event.resourceID)
                case .delete:
                    self?.deleteChannelFromStorage(with: event.resourceID)
                    DispatchQueue.main.async { [weak self] in
                        self?.delegate?.didDeleteChannel(with: event.resourceID)
                    }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - DataService

extension DataServiceImpl: DataService {
    
    // MARK: - CoreData methods
    
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
            logService.success("Channels received")
            self.channels = channels
            self.channelsPublisher.send(self.channels)
        } catch {
            logService.error("Channels not received")
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
                logService.info("Channel updated")
            } else {
                let channelManagedObject = ChannelManagedObject(context: context)
                channelManagedObject.id = channelModel.id
                channelManagedObject.name = channelModel.name
                channelManagedObject.logoURL = channelModel.logoUrl
                channelManagedObject.lastMessage = channelModel.lastMessage
                channelManagedObject.lastActivity = channelModel.lastActivity
                channelManagedObject.messages = NSOrderedSet()
                logService.info("Channel added")
            }
        }
    }
    
    private func deleteChannelFromStorage(with channelId: String) {
        coreDataService.update { context in
            let fetchRequest = ChannelManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", channelId as CVarArg)
            guard
                let channelManagedObject = try context.fetch(fetchRequest).first
            else {
                logService.error("The channel is not deleted from the database")
                return
            }
            context.delete(channelManagedObject)
            logService.info("The channel has been deleted from the database")
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
            logService.info("Messages received")
            self.messages = messages
            self.messagesPublisher.send(self.messages)
        } catch {
            logService.error("Messages not received")
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
                logService.info("Messages added")
            }
        }
    }
    
    // MARK: - ChatTransportService methods
    
    func loadChannelsFromNetwork() {
        chatTransportService.loadChannels()
            .sink { [weak self] _ in
                self?.updateChannelsFromStorage()
            } receiveValue: { [weak self] channelModels in
                channelModels.forEach { channelModel in
                    self?.saveChannelInStorage(with: channelModel)
                    self?.logService.success("Channels loaded")
                }
            }
            .store(in: &cancellables)
    }
    
    func loadChannelFromNetwork(for channelId: String) {
        chatTransportService.loadChannel(with: channelId)
            .sink { [weak self] _ in
                self?.updateChannelsFromStorage()
            } receiveValue: { [weak self] channelModel in
                self?.saveChannelInStorage(with: channelModel)
                self?.logService.success("Channel loaded")
            }
            .store(in: &cancellables)

    }
    
    func createChannelInNetwork(name: String, logoUrl: String?, _ completion: @escaping (ChannelModel) -> Void) {
        chatTransportService.createChannel(name: name, logoUrl: logoUrl)
            .receive(on: DispatchQueue.main)
            .sink { _ in }
            receiveValue: { [weak self] channelModel in
                self?.saveChannelInStorage(with: channelModel)
                completion(channelModel)
                self?.logService.success("The channel is created and saved to the database")
            }
            .store(in: &cancellables)
    }
    
    func deleteChannelFromNetwork(with channelId: String) {
        chatTransportService.deleteChannel(with: channelId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.logService.success("The channel is deleted on the server")
                case .failure:
                    self?.deleteChannelFromStorage(with: channelId)
                }
            }
            receiveValue: {}
            .store(in: &cancellables)
    }
    
    func loadMessagesFromNetwork(for channelId: String) {
        chatTransportService.loadMessages(for: channelId)
            .sink { [weak self] _ in
                self?.updateMessagesFromStorage(for: channelId)
            } receiveValue: { [weak self] messageModels in
                messageModels.forEach { messageModel in
                    self?.saveMessageModelInStorage(with: messageModel, in: channelId)
                }
            }
            .store(in: &cancellables)
    }
    
    func sendMessage(text: String, channelId: String, userId: String, userName: String) {
        chatTransportService.sendMessage(text: text, channelId: channelId, userId: userId, userName: userName)
            .sink { [weak self] _ in
                self?.updateMessagesFromStorage(for: channelId)
                self?.loadChannelFromNetwork(for: channelId)
            } receiveValue: { [weak self] newMessage in
                self?.saveMessageModelInStorage(with: newMessage, in: channelId)
            }
            .store(in: &cancellables)
    }
}
