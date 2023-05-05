import UIKit
import Combine

final class PhotoSelectionPresenter {
    private let photoLoaderService: PhotoLoaderService
    weak var viewInput: PhotoSelectionViewInput?
    weak var delegate: PhotoSelectionDelegate?
    
    private var photos: [PhotoModel] = []
    
    init(photoLoaderService: PhotoLoaderService, delegate: PhotoSelectionDelegate) {
        self.photoLoaderService = photoLoaderService
        self.delegate = delegate
    }
    
    private func didLoadPhoto(_ photos: [PhotoModel]) {
        viewInput?.updatePhotos(photos)
    }
}

// MARK: - PhotoSelectionViewOutput

extension PhotoSelectionPresenter: PhotoSelectionViewOutput {
    func didSelectPhotoModel(with photoModel: PhotoModel) {
        delegate?.didSelectPhotoModel(with: photoModel)
    }
    
    var photosCount: Int {
        photos.count
    }
    
    func didRequestPhoto(by photo: PhotoModel, completion: @escaping (UIImage?) -> Void) {
        photoLoaderService.fetchPhoto(by: photo.webformatURL) { result in
            switch result {
            case .success(let photo):
                completion(photo)
            case .failure:
                completion(nil)
            }
        }
    }
    
    func loadPhoto() {
        photoLoaderService.fetchPhotosNextPage { [weak self] result in
            switch result {
            case .success(let photos):
                self?.photos.append(contentsOf: photos)
                self?.didLoadPhoto(photos)
            case .failure:
                self?.viewInput?.showErrorAlert(with: "Failed to upload photo")
            }
        }
    }
    
    func viewIsReady() {
        loadPhoto()
    }
}
