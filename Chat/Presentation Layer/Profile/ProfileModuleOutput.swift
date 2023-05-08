import UIKit

protocol ProfileModuleOutput: AnyObject {
    func moduleWantsToOpenPhotoSelection(with delegate: PhotoSelectionDelegate)
    
    func moduleWantsToOpenProfileEdit(
        with profileModel: ProfileModel,
        transitioningDelegate: UIViewControllerTransitioningDelegate,
        delegate: ProfileEditDelegate
    )
}
