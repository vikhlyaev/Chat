import Foundation

struct SortedMessage {
    let date: Date
    var messages: [MessageModel]
    
    mutating func addMessage(_ message: MessageModel) {
        messages.insert(message, at: 0)
    }
}

protocol DayCategorizable {
    var date: Date { get }
}
