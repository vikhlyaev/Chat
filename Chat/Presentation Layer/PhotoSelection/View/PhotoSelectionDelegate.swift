import UIKit

protocol PhotoSelectionDelegate: AnyObject {
    func didSelectPhotoModel(with photoModel: PhotoModel)
}
