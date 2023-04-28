import UIKit

protocol SettingsViewOutput {
    var currentTheme: UIUserInterfaceStyle { get }
    func didButtonTapped(theme: UIUserInterfaceStyle)
}
