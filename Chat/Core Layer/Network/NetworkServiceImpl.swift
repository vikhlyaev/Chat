import Foundation

final class NetworkServiceImpl {
    private let session: URLSession
    private let logService: LogService
    
    init(session: URLSession, logService: LogService) {
        self.session = session
        self.logService = logService
    }
}

// MARK: - NetworkService

extension NetworkServiceImpl: NetworkService {
    func fetch<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    do {
                        let object = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(object))
                        self?.logService.success("Data decoded")
                    } catch {
                        completion(.failure(NetworkError.parsingJsonError(error)))
                        self?.logService.error("Data not decoded. Error: \(error)")
                    }
                } else {
                    completion(.failure(NetworkError.httpStatusCode(statusCode)))
                    self?.logService.error("HTTP Status code: \(statusCode)")
                }
            } else if let error = error {
                completion(.failure(NetworkError.urlRequestError(error)))
                self?.logService.error("URLRequest error: \(error)")
            } else {
                completion(.failure(NetworkError.urlSessionError))
                self?.logService.error("URLSession error")
            }
        }).resume()
    }
}
