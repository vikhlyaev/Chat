import UIKit

protocol PhotoSelectionDelegate: AnyObject {
    func didSelectPhotoModel(with photo: UIImage)
}
