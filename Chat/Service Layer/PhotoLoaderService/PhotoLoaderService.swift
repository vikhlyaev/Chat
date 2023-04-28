import UIKit

protocol PhotoLoaderService {
    func fetchPhotosNextPage(_ completion: @escaping (Result<[Photo], Error>) -> Void)
    func downloadPhoto(by url: String, _ completion: @escaping(Result<UIImage, Error>) -> Void)
}
