import UIKit

protocol PhotoSelectionCellDelegate: AnyObject {
    func didRecievePhoto(for photoModel: PhotoModel, _ completion: @escaping (UIImage?) -> Void)
}
