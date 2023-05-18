import Foundation

protocol ProfileModuleOutput: AnyObject {
    func moduleWantsToOpenPhotoSelection(with delegate: PhotoSelectionDelegate)
}
