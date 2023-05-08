import UIKit

final class AlertCreatorServiceImpl: AlertCreatorService {
    
    weak var delegate: AlertActionDelegate?
    
    func makeAlert(with alertModel: AlertViewModel) -> UIViewController {
        let vc = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: alertModel.style
        )
        
        if alertModel.enableOkAction {
            let okAction = UIAlertAction(
                title: alertModel.okActionTitle,
                style: alertModel.okActionStyle
            ) { _ in
                self.delegate?.okAction()
            }
            vc.addAction(okAction)
        }
        
        if alertModel.enableCancelAction {
            let cancelAction = UIAlertAction(
                title: alertModel.cancelActionTitle,
                style: alertModel.cancelActionStyle
            ) { _ in
                self.delegate?.cancelAction()
            }
            vc.addAction(cancelAction)
        }
        
        return vc
    }
    
    func makePhotoAddingAlertSheet(
        takePhotoAction: @escaping () -> Void,
        chooseFromGalleryAction: @escaping () -> Void,
        loadFromNetworkAction: @escaping () -> Void
    ) -> UIViewController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take photo", style: .default) { _ in
            takePhotoAction()
        }
        let chooseFromGalleryAction = UIAlertAction(title: "Choose from gallery", style: .default) { _ in
            chooseFromGalleryAction()
        }
        let loadFromNetworkAction = UIAlertAction(title: "Load from network", style: .default) { _ in
            loadFromNetworkAction()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(takePhotoAction)
        alert.addAction(chooseFromGalleryAction)
        alert.addAction(loadFromNetworkAction)
        alert.addAction(cancelAction)
        return alert
    }
}
