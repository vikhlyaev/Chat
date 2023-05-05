import UIKit

protocol ProfileEditModuleOutput: AnyObject {
    func moduleWantsToOpenPhotoSelection(with delegate: PhotoSelectionDelegate)
}
