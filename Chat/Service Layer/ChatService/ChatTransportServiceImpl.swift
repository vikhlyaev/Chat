import Foundation
import TFSChatTransport
import Combine

final class ChatTransportServiceImpl {
    private let chatService: ChatService
    private var cancellables = Set<AnyCancellable>()
    private let host = Bundle.main.object(forInfoDictionaryKey: "Chat Service IP") as? String
    private let port = Bundle.main.object(forInfoDictionaryKey: "Chat Service Port") as? String
    
    init() {
        self.chatService = ChatService(
            host: host ?? "",
            port: Int(port ?? "") ?? 80
        )
    }
}

// MARK: - ChatTransportService

extension ChatTransportServiceImpl: ChatTransportService {
    func createChannel(name: String, logoUrl: String?) -> AnyPublisher<ChannelModel, Error> {
        chatService.createChannel(name: name, logoUrl: logoUrl)
            .map { ChannelModel(id: $0.id,
                                name: $0.name,
                                logoUrl: $0.logoURL,
                                lastMessage: $0.lastMessage,
                                lastActivity: $0.lastActivity) }
            .eraseToAnyPublisher()
    }
    
    func loadChannels() -> AnyPublisher<[ChannelModel], Error> {
        chatService.loadChannels()
            .map { $0.map { ChannelModel(id: $0.id,
                                         name: $0.name,
                                         logoUrl: $0.logoURL,
                                         lastMessage: $0.lastMessage,
                                         lastActivity: $0.lastActivity)
            }}
            .eraseToAnyPublisher()
    }
    
    func loadChannel(with channelId: String) -> AnyPublisher<ChannelModel, Error> {
        chatService.loadChannel(id: channelId)
            .map { ChannelModel(id: $0.id,
                                name: $0.name,
                                logoUrl: $0.logoURL,
                                lastMessage: $0.lastMessage,
                                lastActivity: $0.lastActivity)
            }
            .eraseToAnyPublisher()
    }
    
    func deleteChannel(with channelId: String) -> AnyPublisher<Void, Error> {
        chatService.deleteChannel(id: channelId)
    }

    func loadMessages(for channelId: String) -> AnyPublisher<[MessageModel], Error> {
        chatService.loadMessages(channelId: channelId)
            .map { $0.map { MessageModel(id: $0.userID,
                                         text: $0.text,
                                         userID: $0.userID,
                                         userName: $0.userName,
                                         date: $0.date)
            }}
            .eraseToAnyPublisher()
    }

    func sendMessage(text: String, channelId: String, userId: String, userName: String) -> AnyPublisher<MessageModel, Error> {
        chatService.sendMessage(text: text, channelId: channelId, userId: userId, userName: userName)
            .map { MessageModel(id: $0.userID,
                                text: $0.text,
                                userID: $0.userID,
                                userName: $0.userName,
                                date: $0.date)
            }
            .eraseToAnyPublisher()
    }
}
