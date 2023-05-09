import UIKit

protocol AlertCreatorService {
    func makeAlert(with alertModel: AlertViewModel) -> UIViewController
    
    func makePhotoAddingAlertSheet(
        takePhotoAction: @escaping () -> Void,
        chooseFromGalleryAction: @escaping () -> Void,
        loadFromNetworkAction: @escaping () -> Void
    ) -> UIViewController
}
