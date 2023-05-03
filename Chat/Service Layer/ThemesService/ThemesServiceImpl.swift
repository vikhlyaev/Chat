import UIKit

final class ThemesServiceImpl {
    private let key = "CurrentTheme"
}

// MARK: - ThemesService

extension ThemesServiceImpl: ThemesService {
    var currentTheme: UIUserInterfaceStyle {
        get {
            UIUserInterfaceStyle(rawValue: UserDefaults.standard.integer(forKey: key)) ?? .light
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = currentTheme
        }
    }
}
