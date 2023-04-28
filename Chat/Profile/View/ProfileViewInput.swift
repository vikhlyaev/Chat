import UIKit

protocol ProfileViewInput: AnyObject {
    func showProfile(with model: ProfileModel)
    func showErrorAlert()
    func showSuccessAlert()
    func showController(_ controller: UIViewController)
    func startActivityIndicator()
    func stopActivityIndicator()
    func updatePhoto(_ photo: UIImage)
}
