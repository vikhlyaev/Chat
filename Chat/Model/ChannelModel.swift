import Foundation

struct ChannelModel: Decodable, Hashable {
    let id: String
    let name: String
    let logoUrl: String?
    let lastMessage: String?
    let lastActivity: Date?
}

extension ChannelModel: Equatable {
    static func == (lhs: ChannelModel, rhs: ChannelModel) -> Bool {
        return
            lhs.id == rhs.id
    }
}
