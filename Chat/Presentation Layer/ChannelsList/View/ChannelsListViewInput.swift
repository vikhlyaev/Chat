import Foundation

protocol ChannelsListViewInput: AnyObject {
    func showChannels(_ channelModels: [ChannelModel])
    func deleteChannel(with channelId: String)
}
