import UIKit

struct AlertViewModel {
    let title: String
    let message: String?
    let button: AlertButton
    let secondaryButton: AlertButton?
    
    init(title: String, message: String?, button: AlertButton, secondaryButton: AlertButton? = nil) {
        self.title = title
        self.message = message
        self.button = button
        self.secondaryButton = secondaryButton
    }
}

struct AlertButton {
    let text: String
    let action: (() -> Void)?
}
