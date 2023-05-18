import Foundation

protocol DataServiceDelegate: AnyObject {
    func didDeleteChannel(with channelId: String)
}
