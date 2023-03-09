import Foundation

struct Message: DayCategorizable {
    let text: String
    var date: Date
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

protocol DayCategorizable {
    var date: Date { get }
}

