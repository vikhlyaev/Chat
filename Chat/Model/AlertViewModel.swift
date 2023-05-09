import UIKit

struct AlertViewModel {
    
    struct AlertAction {
        let title: String
        let style: UIAlertAction.Style
        var completion: ((UIAlertAction) -> Void)?
        
        init(title: String, style: UIAlertAction.Style, completion: ((UIAlertAction) -> Void)? = nil) {
            self.title = title
            self.style = style
            self.completion = completion
        }
    }
    
    let title: String
    let message: String
    let style: UIAlertController.Style
    let firstAction: AlertAction
    var secondAction: AlertAction?
    
    init(
        title: String,
        message: String,
        style: UIAlertController.Style = .alert,
        firstAction: AlertAction,
        secondAction: AlertAction? = nil
    ) {
        self.title = title
        self.message = message
        self.style = style
        self.firstAction = firstAction
        self.secondAction = secondAction
    }
}
