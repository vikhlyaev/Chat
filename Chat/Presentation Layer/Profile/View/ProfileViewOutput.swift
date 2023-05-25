import UIKit

protocol ProfileViewOutput {
    func viewIsReady()
    func didOpenProfileEdit(with transitioningDelegate: UIViewControllerTransitioningDelegate)
    func didOpenPhotoAddingAlertSheet()
}
