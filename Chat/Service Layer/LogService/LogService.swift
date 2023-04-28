import Foundation

protocol LogService {
    func success(_ message: String)
    func error(_ message: String)
    func info(_ message: String)
}
