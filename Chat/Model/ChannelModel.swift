import Foundation

struct ChannelModel {
    let id: String
    let name: String
    let logoURL: String?
    let lastMessage: String?
    let lastActivity: Date?
}

extension ChannelModel: Equatable {
    static func == (lhs: ChannelModel, rhs: ChannelModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

extension ChannelModel: Decodable {}
extension ChannelModel: Hashable {}
