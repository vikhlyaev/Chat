import Foundation

protocol ChannelsListModuleOutput: AnyObject {
    func moduleWantsToOpenChannel(with channel: ChannelModel)
}
