import UIKit

protocol ThemesManagerProtocol: AnyObject {
    func apply(theme: UIUserInterfaceStyle)
}

final class ThemesManager {
    private let key = "CurrentTheme"
    var currentTheme: UIUserInterfaceStyle {
        UIUserInterfaceStyle(rawValue: UserDefaults.standard.integer(forKey: key)) ?? .light
    }
}

// MARK: - ThemesManagerProtocol

extension ThemesManager: ThemesManagerProtocol {        
    func apply(theme: UIUserInterfaceStyle) {
        UserDefaults.standard.set(theme.rawValue, forKey: key)
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = theme
    }
}
