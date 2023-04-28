import Foundation
import OSLog

final class LogServiceImpl {
    private var logger: Logger {
        if ProcessInfo.processInfo.environment.keys.contains(name) {
            return Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: name)
        } else {
            return Logger(.disabled)
        }
    }
    
    private let name: String
    
    init(name: String) {
        self.name = name
        setEnvironmentVar(name: name, value: "", overwrite: true)
    }
    
    private func setEnvironmentVar(name: String, value: String, overwrite: Bool) {
        setenv(name, value, overwrite ? 1 : 0)
    }
}

// MARK: - LogService

extension LogServiceImpl: LogService {
    func success(_ message: String) {
        logger.info("🟢 \(message)")
    }
    
    func error(_ message: String) {
        logger.error("🔴 \(message)")
    }
    
    func info(_ message: String) {
        logger.info("🟡 \(message)")
    }
}
