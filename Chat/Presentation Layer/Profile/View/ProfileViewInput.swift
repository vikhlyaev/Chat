import UIKit

protocol ProfileViewInput: AnyObject {
    func showProfile(with model: ProfileModel)
    func showErrorAlert(with text: String)
    func showSuccessAlert()
    func showController(_ controller: UIViewController)
    func updatePhoto(_ photo: UIImage)
}
