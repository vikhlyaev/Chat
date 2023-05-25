import UIKit
import Combine

final class PhotoSelectionPresenter {
    private let photoLoaderService: PhotoLoaderService
    private let alertCreatorService: AlertCreatorService
    weak var viewInput: PhotoSelectionViewInput?
    weak var delegate: PhotoSelectionDelegate?
    
    private var photos: [PhotoModel] = []
    
    init(
        photoLoaderService: PhotoLoaderService,
        alertCreatorService: AlertCreatorService,
        delegate: PhotoSelectionDelegate
    ) {
        self.photoLoaderService = photoLoaderService
        self.alertCreatorService = alertCreatorService
        self.delegate = delegate
    }
    
    private func didLoadPhoto(_ photos: [PhotoModel]) {
        viewInput?.updatePhotos(photos)
    }
}

// MARK: - PhotoSelectionViewOutput

extension PhotoSelectionPresenter: PhotoSelectionViewOutput {
    var photosCount: Int {
        photos.count
    }
    
    func viewIsReady() {
        loadPhoto()
    }
    
    func loadPhoto() {
        photoLoaderService.fetchPhotosNextPage { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let photos):
                self.photos.append(contentsOf: photos)
                self.didLoadPhoto(photos)
            case .failure:
                let alert = self.alertCreatorService.makeAlert(
                    with: AlertViewModel(
                        title: "Error",
                        message: "Unable to upload a profile photo",
                        firstAction: AlertViewModel.AlertAction(
                            title: "OK",
                            style: .cancel
                        )
                    )
                )
                self.viewInput?.showAlert(alert)
            }
        }
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
    
    func didSelectPhotoModel(with photoModel: PhotoModel) {
        delegate?.didSelectPhotoModel(with: photoModel)
    }
}
