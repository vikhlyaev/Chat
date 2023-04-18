import Foundation
import TFSChatTransport

struct SortedMessage {
    let date: Date
    var messages: [Message]
    
    mutating func addMessage(_ message: Message) {
        messages.insert(message, at: 0)
    }
}

protocol DayCategorizable {
    var date: Date { get }
}
