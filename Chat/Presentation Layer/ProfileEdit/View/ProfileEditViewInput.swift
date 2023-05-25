import UIKit

protocol ProfileEditViewInput: AnyObject {
    func updatePhoto(_ photo: UIImage)
    func showController(_ controller: UIViewController)
    func startActivityIndicator()
    func stopActivityIndicator()
}
