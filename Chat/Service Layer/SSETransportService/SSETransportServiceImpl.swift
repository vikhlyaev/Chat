import Foundation
import TFSChatTransport
import Combine

final class SSETransportServiceImpl {
    private var sseService: SSEService?
    private var cancellables = Set<AnyCancellable>()
    private let host = Bundle.main.object(forInfoDictionaryKey: "Chat Service IP") as? String
    private let port = Bundle.main.object(forInfoDictionaryKey: "Chat Service Port") as? String
}

extension SSETransportServiceImpl: SSETransportService {
    func subscribeOnEvents() -> AnyPublisher<ChatEvent, Error>? {
        if let host, let port, let portInt = Int(port) {
            sseService = SSEService(
                host: host,
                port: portInt
            )
            return sseService?.subscribeOnEvents()
        }
        return nil
    }
    
    func cancelSubscription() {
        sseService?.cancelSubscription()
        sseService = nil
    }
}
