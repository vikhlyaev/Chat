import UIKit

protocol PhotoAddingServiceDelegate: AnyObject {
    func updatePhoto(_ photo: UIImage)
    func showController(_ controller: UIViewController)
}
