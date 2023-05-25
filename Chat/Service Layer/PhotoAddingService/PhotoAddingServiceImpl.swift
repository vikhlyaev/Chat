import UIKit
import PhotosUI

final class PhotoAddingServiceImpl: NSObject, UINavigationControllerDelegate {
    private var imagePicker: UIImagePickerController?
    weak var delegate: PhotoAddingServiceDelegate?
}

// MARK: - PhotoAddingService

extension PhotoAddingServiceImpl: PhotoAddingService {
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
            self?.delegate?.showController(imagePicker)
        }
    }
    
    func didChooseFromGallery() {
        let configuration = PHPickerConfiguration()
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.showController(picker)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension PhotoAddingServiceImpl: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            if let image = image as? UIImage {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.updatePhoto(image)
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension PhotoAddingServiceImpl: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imagePicker = imagePicker,
              let image = info[.originalImage] as? UIImage else { return }
        imagePicker.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.updatePhoto(image)
        }
    }
}
