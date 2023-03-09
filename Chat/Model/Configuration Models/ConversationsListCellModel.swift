import UIKit

struct ConversationsListCellModel {
    let name: String
    var message: String?
    var date: Date?
    let isOnline: Bool
    let hasUnreadMessages: Bool
    var photo: UIImage
}
