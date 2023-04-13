import Foundation

protocol MessageProtocol {
    var id: String { get }
    var text: String { get }
    var userID: String { get }
    var userName: String { get }
    var date: Date { get }
}
