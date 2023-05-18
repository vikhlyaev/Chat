import Foundation

protocol NetworkService {
    func fetch<T: Decodable>(for request: URLRequest, _ completion: @escaping (Result<T, Error>) -> Void)
    func download(with request: URLRequest, _ completion: @escaping (Result<Data, Error>) -> Void)
}
