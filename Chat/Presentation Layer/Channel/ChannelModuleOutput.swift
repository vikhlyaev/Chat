import Foundation

protocol ChannelModuleOutput: AnyObject {
    func moduleWantsToOpenPhotoSelection(with delegate: PhotoSelectionDelegate)
}
