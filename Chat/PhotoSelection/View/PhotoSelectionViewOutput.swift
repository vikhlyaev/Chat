import UIKit

protocol PhotoSelectionViewOutput {
    var photos: [UIImage] { get }
    func viewIsReady()
}
