import Foundation
import TFSChatTransport
import Combine

protocol ChatTransportService {
    func createChannel(name: String, logoUrl: String?) -> AnyPublisher<ChannelModel, Error>
    func loadChannels() -> AnyPublisher<[ChannelModel], Error>
    func deleteChannel(with channelId: String) -> AnyPublisher<Void, Error>
    func loadMessages(for channelId: String) -> AnyPublisher<[MessageModel], Error>
    func sendMessage(text: String, channelId: String, userId: String, userName: String) -> AnyPublisher<MessageModel, Error>
}
