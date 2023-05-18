import Foundation
import TFSChatTransport
import Combine

protocol SSETransportService {
    func subscribeOnEvents() -> AnyPublisher<ChatEvent, Error>?
    func cancelSubscription()
}
