import UIKit

protocol SettingsViewInput: AnyObject {
    func setInitialState(currentTheme: UIUserInterfaceStyle)
}
