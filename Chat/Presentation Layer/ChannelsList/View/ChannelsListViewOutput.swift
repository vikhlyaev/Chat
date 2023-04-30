import Foundation

protocol ChannelsListViewOutput {
    func viewIsReady()
    func didUpdateChannels()
    func didCreateChannel(with name: String, and logoUrl: String?)
    func didDeleteChannel(with channelModel: ChannelModel)
}
