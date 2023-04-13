import Foundation

struct ChannelModel: Decodable, ChannelProtocol {
    let id: String
    let name: String
    let logoURL: String?
    let lastMessage: String?
    let lastActivity: Date?
}
