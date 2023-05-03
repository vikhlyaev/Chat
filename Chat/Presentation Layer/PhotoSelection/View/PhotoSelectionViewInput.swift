import Foundation

protocol PhotoSelectionViewInput: AnyObject {
    func updatePhotos(_ photos: [PhotoModel])
    func showErrorAlert(with text: String)
}
