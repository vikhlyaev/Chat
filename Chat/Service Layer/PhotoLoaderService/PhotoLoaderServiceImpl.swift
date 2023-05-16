import Foundation
import UIKit

final class PhotoLoaderServiceImpl {
    
    private let networkService: NetworkService
    
    private let baseUrl = URL(string: "https://pixabay.com/api/")
    private let searchKeyword = "mountains"
    private var lastLoadedPage: Int?
    
    private let backgroundQueue = DispatchQueue(label: "PhotoLoaderService", qos: .userInitiated)
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    private func makeHTTPRequest(with keyword: String, for page: Int) throws -> URLRequest {
        guard
            let baseUrl,
            var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        else { throw PhotoLoaderError.invalidRequest }
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: "35861770-94831b655d8cb35ee0929d805"),
            URLQueryItem(name: "q", value: keyword),
            URLQueryItem(name: "image_type", value: "true"),
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        guard let url = urlComponents.url else { throw PhotoLoaderError.invalidRequest }
        return URLRequest(url: url)
    }
}

// MARK: - PhotoLoaderService

extension PhotoLoaderServiceImpl: PhotoLoaderService {
    func fetchPhotosNextPage(_ completion: @escaping (Result<[PhotoModel], Error>) -> Void) {
        let completionOnMainQueue: (Result<[PhotoModel], Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let nextPage = lastLoadedPage == nil ? 1 : (lastLoadedPage ?? 0) + 1
        guard let request = try? makeHTTPRequest(with: searchKeyword, for: nextPage) else { return }
        networkService.fetch(for: request) { [weak self] (result: Result<PhotoResult, Error>)  in
            switch result {
            case .success(let photoResult):
                self?.lastLoadedPage = nextPage
                completionOnMainQueue(.success(photoResult.photos))
            case .failure(let error):
                completionOnMainQueue(.failure(error))
            }
        }
    }
    
    func fetchPhoto(by url: String, _ completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(PhotoLoaderError.incorrectUrl))
            return
        }
        let completionOnMainQueue: (Result<UIImage, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let request = URLRequest(url: url)
        networkService.download(with: request) { result in
            switch result {
            case .success(let photoData):
                if let photo = UIImage(data: photoData) {
                    completionOnMainQueue(.success(photo))
                } else {
                    completionOnMainQueue(.failure(PhotoLoaderError.incorrectData))
                }
            case .failure(let error):
                completionOnMainQueue(.failure(error))
            }
        }
    }
    
    func fetchPhotoData(by url: String, _ completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(PhotoLoaderError.incorrectUrl))
            return
        }
        let completionOnMainQueue: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let request = URLRequest(url: url)
        networkService.download(with: request) { result in
            switch result {
            case .success(let photoData):
                completionOnMainQueue(.success(photoData))
            case .failure(let error):
                completionOnMainQueue(.failure(error))
            }
        }
    }
}
