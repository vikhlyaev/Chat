import Foundation
import Combine

protocol DataService {
    var channelsPublisher: CurrentValueSubject<[ChannelModel], Never> { get }
    var messagesPublisher: CurrentValueSubject<[MessageModel], Never> { get }
    func loadChannelsFromNetwork()
    func createChannelInNetwork(name: String, logoUrl: String?)
    func deleteChannelFromNetwork(with channelModel: ChannelModel)
    func loadMessagesFromNetwork(for channelId: String)
    func sendMessage(text: String, channelId: String, userId: String, userName: String)
}
