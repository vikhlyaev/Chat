import UIKit

protocol ProfileEditViewInput: AnyObject {
    func updatePhoto(_ photo: UIImage)
    func showViewController(_ viewController: UIViewController)
    func showErrorAlert(with text: String)
    func showSuccessAlert()
}
