import Foundation

protocol ChannelProtocol {
    var id: String { get }
    var name: String { get }
    var logoURL: String? { get }
    var lastMessage: String? { get }
    var lastActivity: Date? { get }
}
