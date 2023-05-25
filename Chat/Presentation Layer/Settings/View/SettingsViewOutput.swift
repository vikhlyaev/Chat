import UIKit

protocol SettingsViewOutput {
    var currentTheme: UIUserInterfaceStyle { get }
    func viewIsReady()
    func didButtonTapped(theme: UIUserInterfaceStyle)
}
