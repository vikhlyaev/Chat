import UIKit

protocol PhotoSelectionViewOutput {
    var photos: [Photo] { get }
    var photosCount: Int { get }
    func didRequestPhoto(by index: Int) -> UIImage
    func viewIsReady()
    func didLoadNextPhoto()
}
