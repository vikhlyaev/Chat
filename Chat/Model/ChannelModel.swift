import Foundation

struct ChannelModel: Decodable, Hashable, Equatable {
    let id: String
    let name: String
    let logoUrl: String?
    let lastMessage: String?
    let lastActivity: Date?
}
