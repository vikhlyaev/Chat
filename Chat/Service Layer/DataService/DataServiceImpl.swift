import Foundation
import TFSChatTransport
import Combine

final class DataServiceImpl {
    
    // MARK: - Services
    
    private let coreDataService: CoreDataService
    private let chatTransportService: ChatTransportService
    private let logService: LogService
    
    // MARK: - Storages
    
    private var messages: [MessageModel] = []
    private var channels: [ChannelModel] = []
    
    // MARK: - Publishers
    
    lazy var channelsPublisher = CurrentValueSubject<[ChannelModel], Never>(channels)
    lazy var messagesPublisher = CurrentValueSubject<[MessageModel], Never>(messages)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(coreDataService: CoreDataService, chatTransportService: ChatTransportService, logService: LogService) {
        self.coreDataService = coreDataService
        self.chatTransportService = chatTransportService
        self.logService = logService
        
        loadChannelsFromNetwork()
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
    
    private func deleteChannelFromStorage(with channelModel: ChannelModel) {
        coreDataService.update { context in
            let fetchRequest = ChannelManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", channelModel.id as CVarArg)
            guard
                let channelManagedObject = try context.fetch(fetchRequest).first
            else {
                logService.error("Channel has not been deleted")
                fatalError()
            }
            context.delete(channelManagedObject)
            logService.info("Channel deleted")
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
    
    func createChannelInNetwork(name: String, logoUrl: String?) {
        chatTransportService.createChannel(name: name, logoUrl: logoUrl)
            .sink { [weak self] _ in
                self?.updateChannelsFromStorage()
            } receiveValue: { [weak self] channelModel in
                self?.saveChannelInStorage(with: channelModel)
                self?.logService.success("Channel created")
            }
            .store(in: &cancellables)
    }
    
    func deleteChannelFromNetwork(with channelModel: ChannelModel) {
        chatTransportService.deleteChannel(with: channelModel.id)
            .sink { [weak self] _ in
                self?.deleteChannelFromStorage(with: channelModel)
            } receiveValue: {}
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
            } receiveValue: { [weak self] newMessage in
                self?.saveMessageModelInStorage(with: newMessage, in: channelId)
            }
            .store(in: &cancellables)
    }
}
