import Foundation

protocol PhotoSelectionViewInput: AnyObject {
    func updatePhotos(_ photos: [PhotoModel])
}
