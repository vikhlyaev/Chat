import Foundation
import PhotosUI

final class ProfilePresenter: NSObject {
    private let profileService: ProfileService
    private let photoLoaderService: PhotoLoaderService
    private var photoAddingService: PhotoAddingService
    private let alertCreatorService: AlertCreatorService
    
    private var profileModel: ProfileModel?
    
    weak var moduleOutput: ProfileModuleOutput?
    weak var viewInput: ProfileViewInput?
    
    init(profileService: ProfileService,
         photoLoaderService: PhotoLoaderService,
         photoAddingService: PhotoAddingService,
         alertCreatorService: AlertCreatorService,
         moduleOutput: ProfileModuleOutput?) {
        self.profileService = profileService
        self.photoLoaderService = photoLoaderService
        self.photoAddingService = photoAddingService
        self.alertCreatorService = alertCreatorService
        self.moduleOutput = moduleOutput
    }
    
    private func setDelegates() {
        photoAddingService.delegate = self
    }
    
    private func loadProfile() {
        profileService.loadProfile { [weak self] result in
            switch result {
            case .success(let profileModel):
                self?.profileModel = profileModel
                self?.viewInput?.showProfile(with: profileModel)
            case .failure:
                self?.viewInput?.showErrorAlert(with: "Failed to load profile")
            }
        }
    }
}

// MARK: - ProfileViewOutput

extension ProfilePresenter: ProfileViewOutput {
    func viewIsReady() {
        setDelegates()
        loadProfile()
    }
    
    func didOpenPhotoAddingAlertSheet() {
        guard let viewInput else { return }
        viewInput.showViewController(
            alertCreatorService.makePhotoAddingAlertSheet(
                takePhotoAction: { [weak self] in
                    self?.photoAddingService.didTakePhoto()
                },
                chooseFromGalleryAction: { [weak self] in
                    self?.photoAddingService.didChooseFromGallery()
                },
                loadFromNetworkAction: { [weak self] in
                    guard let self else { return }
                    self.moduleOutput?.moduleWantsToOpenPhotoSelection(withDelegate: self)
                }
            )
        )
    }
    
    func didOpenProfileEdit(with transitioningDelegate: UIViewControllerTransitioningDelegate) {
        guard let profileModel else { return }
        moduleOutput?.moduleWantsToOpenProfileEdit(
            with: profileModel,
            transitioningDelegate: transitioningDelegate,
            delegate: self
        )
    }
}

// MARK: - ProfileEditDelegate

extension ProfilePresenter: ProfileEditDelegate {
    func didUpdateProfile() {
        loadProfile()
    }
}

// MARK: - PhotoAddingServiceDelegate

extension ProfilePresenter: PhotoAddingServiceDelegate {
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

extension ProfilePresenter: PhotoSelectionDelegate {
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
