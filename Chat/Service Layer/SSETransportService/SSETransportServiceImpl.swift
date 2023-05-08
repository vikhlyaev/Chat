import Foundation
import TFSChatTransport
import Combine

final class SSETransportServiceImpl {
    
    private struct SSEServiceSettings {
        static let ip = "167.235.86.234"
        static let port = 8080
    }
    
    private var sseService: SSEService?
    private var cancellables = Set<AnyCancellable>()
}

extension SSETransportServiceImpl: SSETransportService {
    func subscribeOnEvents() -> AnyPublisher<ChatEvent, Error>? {
        sseService = SSEService(
            host: SSEServiceSettings.ip,
            port: SSEServiceSettings.port
        )
        return sseService?.subscribeOnEvents()
    }
    
    func cancelSubscription() {
        sseService?.cancelSubscription()
        sseService = nil
    }
}
