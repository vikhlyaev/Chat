import UIKit

protocol ProfileEditModuleOutput: AnyObject {
    func moduleWantsToOpenPhotoSelection(withDelegate delegate: PhotoSelectionDelegate)
}
