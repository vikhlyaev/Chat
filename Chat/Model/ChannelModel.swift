import Foundation

struct ChannelModel {
    let id: String
    let name: String
    let logoURL: String?
    let lastMessage: String?
    let lastActivity: Date?
}

extension ChannelModel: Decodable {}
extension ChannelModel: Hashable {}
