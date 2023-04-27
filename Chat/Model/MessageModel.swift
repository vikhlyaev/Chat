import Foundation

struct MessageModel: Decodable, Hashable, DayCategorizable {
    let id: String
    let text: String
    let userID: String
    let userName: String
    let date: Date
}
