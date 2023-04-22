import Foundation
import TFSChatTransport

extension ChatService {
    convenience init() {
        self.init(host: "167.235.86.234", port: 8080)
    }
}
