import UIKit

protocol AlertCreatorService {
    var delegate: AlertActionDelegate? { get set }
    
    func makeAlert(with alertModel: AlertViewModel) -> UIViewController
    
    func makePhotoAddingAlertSheet(
        takePhotoAction: @escaping () -> Void,
        chooseFromGalleryAction: @escaping () -> Void,
        loadFromNetworkAction: @escaping () -> Void
    ) -> UIViewController
}
