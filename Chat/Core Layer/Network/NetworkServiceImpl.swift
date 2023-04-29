import Foundation

final class NetworkServiceImpl {
    private let session: URLSession = URLSession.shared
    private var downloadSession: URLSession?
    private let logService: LogService
    
    init(logService: LogService) {
        self.logService = logService
        setupDownloadSession()
    }
    
    private func setupDownloadSession() {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(
            memoryCapacity: 100 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024
        )
        
        downloadSession = URLSession(configuration: configuration)
    }
}

// MARK: - NetworkService

extension NetworkServiceImpl: NetworkService {
    func fetch<T: Decodable>(for request: URLRequest, _ completion: @escaping (Result<T, Error>) -> Void) {
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
    
    func download(with request: URLRequest, _ completion: @escaping (Result<Data, Error>) -> Void) {
        downloadSession?.downloadTask(with: request) { [weak self] location, response, error in
            if let location = location, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    do {
                        let data = try Data(contentsOf: location)
                        completion(.success(data))
                    } catch {
                        completion(.failure(NetworkError.badData))
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
        }.resume()
    }
}
