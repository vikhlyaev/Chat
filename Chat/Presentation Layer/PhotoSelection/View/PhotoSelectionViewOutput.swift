import UIKit

protocol PhotoSelectionViewOutput {
    var photosCount: Int { get }
    func viewIsReady()
    func loadPhoto()
    func didSelectPhotoModel(with photoModel: PhotoModel)
    func didRequestPhoto(by photoModel: PhotoModel, completion: @escaping (UIImage?) -> Void)
}
