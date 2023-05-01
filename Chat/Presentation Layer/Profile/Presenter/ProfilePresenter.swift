import Foundation
import PhotosUI

final class ProfilePresenter: NSObject {
    
    weak var viewInput: ProfileViewInput?
    
    private let profileService: ProfileService
    weak var moduleOutput: ProfileModuleOutput?
    
    var profileModel: ProfileModel?

    private var imagePicker: UIImagePickerController?
    
    init(profileService: ProfileService,
         moduleOutput: ProfileModuleOutput?) {
        self.profileService = profileService
        self.moduleOutput = moduleOutput
    }
    
    private func loadProfile() {
        profileService.loadProfile { [weak self] result in
            switch result {
            case .success(let profileModel):
                self?.profileModel = profileModel
                self?.viewInput?.showProfile(with: profileModel)
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - ProfileViewOutput

extension ProfilePresenter: ProfileViewOutput {
    func viewIsReady() {
        loadProfile()
    }
    
    func didSaveProfile(_ profile: ProfileModel) {
        viewInput?.startActivityIndicator()
        profileService.saveProfile(profile) { [weak self] error in
            guard error != nil else {
                self?.viewInput?.showSuccessAlert()
                self?.viewInput?.stopActivityIndicator()
                return
            }
            self?.viewInput?.showErrorAlert()
            self?.viewInput?.stopActivityIndicator()
        }
    }
    
    func didTakePhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            didChooseFromGallery()
            return
        }
        imagePicker = UIImagePickerController()
        guard let imagePicker = imagePicker else { return }
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.cameraDevice = .front
        DispatchQueue.main.async { [weak self] in
            self?.viewInput?.showController(imagePicker)
        }
    }
    
    func didChooseFromGallery() {
        let configuration = PHPickerConfiguration()
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        DispatchQueue.main.async { [weak self] in
            self?.viewInput?.showController(picker)
        }
    }
    
    func didLoadFromNetwork() {
        moduleOutput?.moduleWantsToOpenPhotoSelection()
    }
}

// MARK: - PhotoSelectionDelegate

extension ProfilePresenter: PhotoSelectionDelegate {
    func didSelectPhotoModel(with photo: UIImage) {
        viewInput?.updatePhoto(photo)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ProfilePresenter: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            if let image = image as? UIImage {
                DispatchQueue.main.async { [weak self] in
                    self?.viewInput?.updatePhoto(image)
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ProfilePresenter: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imagePicker = imagePicker,
              let image = info[.originalImage] as? UIImage else { return }
        imagePicker.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async { [weak self] in
            self?.viewInput?.updatePhoto(image)
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension ProfilePresenter: UINavigationControllerDelegate {}
