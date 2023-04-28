import UIKit

final class PhotoSelectionPresenter {
    
    private let photoLoaderService: PhotoLoaderService
    
    weak var viewInput: PhotoSelectionViewInput?
    
    var photos: [Photo] = []
    
    init(photoLoaderService: PhotoLoaderService) {
        self.photoLoaderService = photoLoaderService
    }
    
}

// MARK: - PhotoSelectionViewOutput

extension PhotoSelectionPresenter: PhotoSelectionViewOutput {
    var photosCount: Int {
        photos.count
    }
    
    func didRequestPhoto(by index: Int) -> UIImage {
        var image: UIImage = UIImage()
        photoLoaderService.downloadPhoto(by: photos[index].previewURL) { result in
            switch result {
            case .success(let success):
                image = success
            case .failure(let failure):
                print(failure)
            }
        }
        return image
    }
    
    func loadPhoto() {
        photoLoaderService.fetchPhotosNextPage { [weak self] result in
            switch result {
            case .success(let photos):
                self?.photos.append(contentsOf: photos)
                print(photos)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func viewIsReady() {
        loadPhoto()
    }
    
    func didLoadNextPhoto() {
        loadPhoto()
    }
}
