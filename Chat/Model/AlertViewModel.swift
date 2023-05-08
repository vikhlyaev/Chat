import UIKit

struct AlertViewModel {
    let title: String
    let message: String
    let style: UIAlertController.Style
    let enableOkAction: Bool
    let okActionTitle: String
    let okActionStyle: UIAlertAction.Style
    let enableCancelAction: Bool
    let cancelActionTitle: String
    let cancelActionStyle: UIAlertAction.Style
    
    init(title: String,
         message: String,
         style: UIAlertController.Style = .alert,
         enableOkAction: Bool,
         okActionTitle: String,
         okActionStyle: UIAlertAction.Style,
         enableCancelAction: Bool = false,
         cancelActionTitle: String = "",
         cancelActionStyle: UIAlertAction.Style = .cancel) {
        self.title = title
        self.message = message
        self.style = style
        self.enableOkAction = enableOkAction
        self.okActionTitle = okActionTitle
        self.okActionStyle = okActionStyle
        self.enableCancelAction = enableCancelAction
        self.cancelActionTitle = cancelActionTitle
        self.cancelActionStyle = cancelActionStyle
    }
}
