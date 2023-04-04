import Foundation

struct Message: DayCategorizable {
    let text: String
    let date: Date
    let userID: String
    let userName: String
    
    let type: MessageType
}

enum MessageType: CaseIterable {
    case sent
    case received
}

protocol DayCategorizable {
    var date: Date { get }
}

struct SortedMessages {
    let date: Date
    let messages: [Message]
}
