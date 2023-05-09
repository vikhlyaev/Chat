import UIKit

final class ProfileEditPresenter {
    var profileModel: ProfileModel?
    
    private let profileService: ProfileService
    private let photoLoaderService: PhotoLoaderService
    private var photoAddingService: PhotoAddingService
    private let alertCreatorService: AlertCreatorService
    
    weak var moduleOutput: ProfileEditModuleOutput?
    weak var delegate: ProfileEditDelegate?
    weak var viewInput: ProfileEditViewInput?
    
    init(
        profileModel: ProfileModel,
        profileService: ProfileService,
        photoLoaderService: PhotoLoaderService,
        photoAddingService: PhotoAddingService,
        alertCreatorService: AlertCreatorService,
        moduleOutput: ProfileEditModuleOutput?,
        delegate: ProfileEditDelegate
    ) {
        self.profileModel = profileModel
        self.profileService = profileService
        self.photoLoaderService = photoLoaderService
        self.photoAddingService = photoAddingService
        self.alertCreatorService = alertCreatorService
        self.moduleOutput = moduleOutput
        self.delegate = delegate
    }
}

extension ProfileEditPresenter: ProfileEditViewOutput {
    func viewIsReady() {
        photoAddingService.delegate = self
        guard let profileModel, let photo = profileModel.photo else { return }
        viewInput?.updatePhoto(photo)
    }
    
    func didSaveProfile(_ profile: ProfileModel) {
        profileService.saveProfile(profile) { [weak self] error in
            guard error != nil else {
                self?.viewInput?.showSuccessAlert()
                return
            }
            self?.viewInput?.showErrorAlert(with: "Failed to save profile")
        }
        
        delegate?.didUpdateProfile()
    }
    
    func didUpdatePhoto() {
        delegate?.didUpdatePhoto()
    }
}

// MARK: - PhotoAddingServiceDelegate

extension ProfileEditPresenter: PhotoAddingServiceDelegate {
    func showViewController(_ viewController: UIViewController) {
        viewInput?.showViewController(viewController)
    }
    
    func updatePhoto(_ photo: UIImage) {
        viewInput?.updatePhoto(photo)
        profileModel?.photo = photo
        guard let profileModel else { return }
        profileService.saveProfile(profileModel) { [weak self] error in
            if error != nil {
                self?.viewInput?.showErrorAlert(with: "Failed to save profile")
            }
        }
    }
}

// MARK: - PhotoSelectionDelegate

extension ProfileEditPresenter: PhotoSelectionDelegate {
    func didSelectPhotoModel(with photoModel: PhotoModel) {
        photoLoaderService.fetchPhoto(by: photoModel.webformatURL) { [weak self] result in
            switch result {
            case .success(let photo):
                self?.updatePhoto(photo)
            case .failure:
                self?.viewInput?.showErrorAlert(with: "Failed to load photo")
            }
        }
    }
}
