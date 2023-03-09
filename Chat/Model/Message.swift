import Foundation

struct Message {
    let text: String
    let date: Date
    let type: MessageType
    
    init(text: String, date: Date, type: MessageType) {
        self.text = text
        self.date = date
        self.type = type
    }
}

enum MessageType: CaseIterable {
    case sent
    case received
}
