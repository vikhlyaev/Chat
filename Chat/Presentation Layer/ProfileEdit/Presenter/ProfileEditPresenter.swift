import UIKit

final class ProfileEditPresenter {
    
    var profileModel: ProfileModel?
    private var tempProfileModel: ProfileModel?
    
    private let profileService: ProfileService
    private let photoLoaderService: PhotoLoaderService
    private var photoAddingService: PhotoAddingService
    private var alertCreatorService: AlertCreatorService
    
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
    
    private func setDelegates() {
        photoAddingService.delegate = self
    }
}

extension ProfileEditPresenter: ProfileEditViewOutput {
    func viewIsReady() {
        setDelegates()
        
        guard
            let profileModel,
            let photo = profileModel.photo
        else { return }
        viewInput?.updatePhoto(photo)
    }
    
    func didSaveProfile(_ profile: ProfileModel) {
        tempProfileModel = profile
        profileService.saveProfile(profile) { [weak self] error in
            guard let self else { return }
            if error != nil {
                let alert = self.alertCreatorService.makeAlert(
                    with: AlertViewModel(
                        title: "Could not save profile",
                        message: "Try again",
                        firstAction: AlertViewModel.AlertAction(
                            title: "Try Again",
                            style: .default,
                            completion: { [weak self] _ in
                                guard let tempProfileModel = self?.tempProfileModel else { return }
                                self?.didSaveProfile(tempProfileModel)
                            }
                        ),
                        secondAction: AlertViewModel.AlertAction(
                            title: "OK",
                            style: .cancel
                        )
                    )
                )
                self.viewInput?.showController(alert)
            } else {
                let alert = self.alertCreatorService.makeAlert(
                    with: AlertViewModel(
                        title: "Success",
                        message: "You are breathtaking",
                        firstAction: AlertViewModel.AlertAction(
                            title: "OK",
                            style: .cancel
                        )
                    )
                )
                self.tempProfileModel = nil
                self.profileModel = profile
                self.viewInput?.showController(alert)
            }
        }
        delegate?.didUpdateProfile()
    }
    
    func didUpdatePhoto() {
        delegate?.didUpdatePhoto()
    }
}

// MARK: - PhotoAddingServiceDelegate

extension ProfileEditPresenter: PhotoAddingServiceDelegate {
    func showController(_ viewController: UIViewController) {
        viewInput?.showController(viewController)
    }
    
    func updatePhoto(_ photo: UIImage) {
        viewInput?.updatePhoto(photo)
        profileModel?.photo = photo
        guard let profileModel else { return }
        profileService.saveProfile(profileModel) { [weak self] error in
            guard let self else { return }
            if error != nil {
                let alert = self.alertCreatorService.makeAlert(
                    with: AlertViewModel(
                        title: "Error",
                        message: "Failed to save profile",
                        firstAction: AlertViewModel.AlertAction(
                            title: "OK",
                            style: .cancel
                        )
                    )
                )
                self.viewInput?.showController(alert)
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
                print("1")
//                self?.viewInput?.showErrorAlert(with: "Failed to load photo")
            }
        }
    }
}
