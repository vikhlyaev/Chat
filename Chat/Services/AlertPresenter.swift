import UIKit

protocol AlertPresenterProtocol {
    func prepare(model: AlertViewModel) -> UIAlertController
}

final class AlertPresenter: AlertPresenterProtocol {
    func prepare(model: AlertViewModel) -> UIAlertController {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: model.button.text, style: .default) { _ in
            if let action = model.button.action {
                action()
            }
        }
        alert.addAction(alertAction)
        
        guard let secondaryButton = model.secondaryButton else { return alert }
        let alertSecondaryAction = UIAlertAction(title: secondaryButton.text, style: .default) { _ in
            if let action = secondaryButton.action {
                action()
            }
        }
        alert.addAction(alertSecondaryAction)
        return alert
    }
}
