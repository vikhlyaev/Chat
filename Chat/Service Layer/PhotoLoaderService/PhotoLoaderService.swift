import UIKit
import Combine

protocol PhotoLoaderService {
    func fetchPhotosNextPage(_ completion: @escaping (Result<[PhotoModel], Error>) -> Void)
    func fetchPhoto(by url: String, _ completion: @escaping (Result<UIImage, Error>) -> Void)
//    func fetchPhotoData(by url: String, _ completion: @escaping (Result<Data, Error>) -> Void)
}
