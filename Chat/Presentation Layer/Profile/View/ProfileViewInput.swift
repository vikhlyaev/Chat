import UIKit

protocol ProfileViewInput: AnyObject {
    func showErrorAlert(with text: String)
    func showProfile(with model: ProfileModel)
    func showViewController(_ viewController: UIViewController)
    func updatePhoto(_ photo: UIImage)
}
