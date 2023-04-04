import Foundation

struct Message: DayCategorizable {
    let text: String
    let date: Date
    let type: MessageType
}

enum MessageType: CaseIterable {
    case sent
    case received
}

protocol DayCategorizable {
    var date: Date { get }
}
