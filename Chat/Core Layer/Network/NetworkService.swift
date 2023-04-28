import Foundation

protocol NetworkService {
    func fetch<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void)
}
