import Foundation

struct MessageModel {
    let id: String
    let text: String
    let userID: String
    let userName: String
    let date: Date
}

extension MessageModel: Decodable {}
extension MessageModel: Hashable {}
extension MessageModel: DayCategorizable {}
