import Foundation
import TFSChatTransport
import Combine

final class SSETransportServiceImpl {
    
    private struct SSEServiceSettings {
        static let ip = "167.235.86.234"
        static let port = 8080
    }
    
    private let sseService: SSEService
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.sseService = SSEService(host: SSEServiceSettings.ip, port: SSEServiceSettings.port)
    }
}

extension SSETransportServiceImpl: SSETransportService {
    func subscribeOnEvents() -> AnyPublisher<ChatEvent, Error> {
        sseService.subscribeOnEvents()
    }
    
    func cancelSubscription() {
        sseService.cancelSubscription()
    }
}
