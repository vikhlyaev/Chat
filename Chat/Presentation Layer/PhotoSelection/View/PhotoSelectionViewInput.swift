import UIKit

protocol PhotoSelectionViewInput: AnyObject {
    func updatePhotos(_ photos: [PhotoModel])
    func showAlert(_ alert: UIViewController)
}
