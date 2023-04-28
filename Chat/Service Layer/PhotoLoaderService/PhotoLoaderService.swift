import Foundation

protocol PhotoLoaderService {
    func fetchPhotosNextPage(_ completion: @escaping (Result<[Photo], Error>) -> Void)
}
