import Foundation
import Combine

protocol DataService {
    var delegate: DataServiceDelegate? { get set }
    var channelsPublisher: CurrentValueSubject<[ChannelModel], Never> { get }
    var messagesPublisher: CurrentValueSubject<[MessageModel], Never> { get }
    func loadChannelsFromNetwork()
    func createChannelInNetwork(name: String, logoUrl: String?, _ completion: @escaping (ChannelModel) -> Void)
    func deleteChannelFromNetwork(with channelId: String)
    func loadMessagesFromNetwork(for channelId: String)
    func sendMessage(text: String, channelId: String, userId: String, userName: String)
}
