import UIKit

final class AlertCreatorServiceImpl: AlertCreatorService {
    
    func makeAlert(with alertModel: AlertViewModel) -> UIViewController {
        let vc = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: alertModel.style
        )
        
        let firstAction = UIAlertAction(
            title: alertModel.firstAction.title,
            style: alertModel.firstAction.style,
            handler: alertModel.firstAction.completion
        )
        
        vc.addAction(firstAction)
        
        if let secondAction = alertModel.secondAction {
            vc.addAction(UIAlertAction(
                title: secondAction.title,
                style: secondAction.style,
                handler: secondAction.completion
            ))
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
