import UIKit

protocol PhotoAddingServiceDelegate: AnyObject {
    func updatePhoto(_ photo: UIImage)
    func showViewController(_ viewController: UIViewController)
}
