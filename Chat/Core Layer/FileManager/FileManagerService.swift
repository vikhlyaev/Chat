import Foundation

protocol FileManagerService {
    func read(by filename: String, _ completion: @escaping (Result<Data, Error>) -> Void)
    func write(_ data: Data, with filename: String, _ completion: @escaping (Error?) -> Void)
}
