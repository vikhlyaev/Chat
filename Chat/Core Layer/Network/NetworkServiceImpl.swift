import Foundation

final class NetworkServiceImpl {
    private let session: URLSession = URLSession.shared
    private let fileManagerService: FileManagerService
    
    init(fileManagerService: FileManagerService) {
        self.fileManagerService = fileManagerService
    }
}

// MARK: - NetworkService

extension NetworkServiceImpl: NetworkService {
    func fetch<T: Decodable>(for request: URLRequest, _ completion: @escaping (Result<T, Error>) -> Void) {
        session.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    do {
                        let object = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(object))
                    } catch {
                        completion(.failure(NetworkError.parsingJsonError(error)))
                    }
                } else {
                    completion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                completion(.failure(NetworkError.urlRequestError(error)))
            } else {
                completion(.failure(NetworkError.urlSessionError))
            }
        }).resume()
    }
    
    func download(with request: URLRequest, _ completion: @escaping (Result<Data, Error>) -> Void) {
        guard let filename = request.url?.lastPathComponent else {
            return
        }
        if fileManagerService.fileExist(at: filename) {
            fileManagerService.read(by: filename) { result in
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
                            self?.fileManagerService.write(data, with: filename) { error in
                                if let error = error {
                                    completion(.failure(error))
                                }
                            }
                            completion(.success(data))
                        } catch {
                            completion(.failure(NetworkError.invalidData))
                        }
                    } else {
                        completion(.failure(NetworkError.httpStatusCode(statusCode)))
                    }
                } else if let error = error {
                    completion(.failure(NetworkError.urlRequestError(error)))
                } else {
                    completion(.failure(NetworkError.urlSessionError))
                }
            }.resume()
        }
    }
    
    func checkImageContentType(with request: URLRequest, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        session.dataTask(with: request) { _, response, error in
            if let response = response, let httpUrlResponse = (response as? HTTPURLResponse) {
                if 200 ..< 300 ~= httpUrlResponse.statusCode {
                    if let contentType = httpUrlResponse.value(forHTTPHeaderField: "Content-Type") {
                        let imagesTypes = ["image/jpeg", "image/png", "image/svg+xml"]
                        completion(.success(imagesTypes.contains(contentType)))
                    }
                } else {
                    completion(.failure(NetworkError.httpStatusCode(httpUrlResponse.statusCode)))
                }
            } else if let error = error {
                completion(.failure(NetworkError.urlRequestError(error)))
            }
        }.resume()
    }
}
