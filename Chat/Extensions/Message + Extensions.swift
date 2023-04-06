import Foundation
import TFSChatTransport

extension Message: DayCategorizable {}

extension Message {
    var type: MessageType {
        guard let id = UserID.value else { return .received }
        return userID == id ? .sent : .received
    }
}
