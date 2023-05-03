import Foundation

final class NetworkServiceImpl {
    private let session: URLSession = URLSession.shared
    private let fileManagerService: FileManagerService
    private let logService: LogService
    
    init(fileManagerService: FileManagerService,
         logService: LogService) {
        self.fileManagerService = fileManagerService
        self.logService = logService
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
        guard let photoName = request.url?.lastPathComponent else { return }
        if fileManagerService.fileExist(at: photoName) {
            fileManagerService.read(by: photoName) { result in
                switch result {
                case .success(let cachedPhotoData):
                    completion(.success(cachedPhotoData))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            session.downloadTask(with: request) { [weak self] location, response, error in
                if let location = location, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200 ..< 300 ~= statusCode {
                        do {
                            let data = try Data(contentsOf: location)
                            self?.fileManagerService.write(data, with: photoName, { error in
                                if let error = error {
                                    completion(.failure(error))
                                }
                            })
                            completion(.success(data))
                        } catch {
                            completion(.failure(NetworkError.invalidData))
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
}
