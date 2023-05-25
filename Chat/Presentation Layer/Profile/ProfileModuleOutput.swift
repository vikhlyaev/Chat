import UIKit

protocol ProfileModuleOutput: AnyObject {
    func moduleWantsToOpenPhotoSelection(withDelegate delegate: PhotoSelectionDelegate)
    
    func moduleWantsToOpenProfileEdit(
        with profileModel: ProfileModel,
        transitioningDelegate: UIViewControllerTransitioningDelegate,
        delegate: ProfileEditDelegate
    )
}
