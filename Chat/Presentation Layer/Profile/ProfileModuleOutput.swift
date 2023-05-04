import UIKit

protocol ProfileModuleOutput: AnyObject {
    func moduleWantsToOpenPhotoSelection(with delegate: PhotoSelectionDelegate)
    func moduleWantsToOpenProfileEdit(with transitioningDelegate: UIViewControllerTransitioningDelegate)
}
