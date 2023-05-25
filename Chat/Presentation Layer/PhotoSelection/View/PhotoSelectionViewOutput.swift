import UIKit

protocol PhotoSelectionViewOutput {
    var photosCount: Int { get }
    func viewIsReady()
    func loadPhoto()
    func didRequestPhoto(by photoModel: PhotoModel, completion: @escaping (UIImage?) -> Void)
    func didSelectPhotoModel(with photoModel: PhotoModel)
}
