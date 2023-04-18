import Foundation

struct SortedMessage {
    let date: Date
    var messages: [MessageModel]
}

protocol DayCategorizable {
    var date: Date { get }
}
