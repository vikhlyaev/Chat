import Foundation
import UIKit

final class PhotoLoaderServiceImpl {
    
    private let networkService: NetworkService
    private let logService: LogService
    
    private let baseUrl = URL(string: "https://pixabay.com/api/")
    private let searchKeyword = "mountains"
    private var lastLoadedPage: Int?
    
    init(networkService: NetworkService, logService: LogService) {
        self.networkService = networkService
        self.logService = logService
    }
    
    private func makeHTTPRequest(with keyword: String, for page: Int) throws -> URLRequest {
        guard
            let baseUrl = baseUrl,
            var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        else {
            throw NetworkError.badRequest
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: "35861770-94831b655d8cb35ee0929d805"),
            URLQueryItem(name: "q", value: keyword),
            URLQueryItem(name: "image_type", value: "true"),
            URLQueryItem(name: "per_page", value: "20"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        guard let url = urlComponents.url else { throw NetworkError.badRequest }
        return URLRequest(url: url)
    }
}

// MARK: - PhotoLoaderService

extension PhotoLoaderServiceImpl: PhotoLoaderService {
    func fetchPhotosNextPage(_ completion: @escaping (Result<[Photo], Error>) -> Void) {
        let completionOnMainQueue: (Result<[Photo], Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage ?? 0 + 1
        guard let request = try? makeHTTPRequest(with: searchKeyword, for: nextPage) else { return }
        networkService.fetch(for: request) { [weak self] (result: Result<PhotoResult, Error>)  in
            switch result {
            case .success(let photoResult):
                completionOnMainQueue(.success(photoResult.photos))
                self?.lastLoadedPage = nextPage
            case .failure(let error):
                completionOnMainQueue(.failure(error))
            }
        }
    }
    
    func downloadPhoto(by url: String, _ completion: @escaping(Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: url) else { return }
        do {
            let data = try Data(contentsOf: url)
            if let photo = UIImage(data: data) {
                completion(.success(photo))
            }
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
}
