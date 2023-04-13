import Foundation

struct MessageModel: Decodable, MessageProtocol {
    let id: String
    let text: String
    let userID: String
    let userName: String
    let date: Date
}
