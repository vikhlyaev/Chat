import UIKit

protocol PhotoAddingService {
    var delegate: PhotoAddingServiceDelegate? { get set }
    func didTakePhoto()
    func didChooseFromGallery()
}
