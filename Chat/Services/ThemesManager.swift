import UIKit

final class ThemesManager {
    private let key = "CurrentTheme"
    var currentTheme: UIUserInterfaceStyle {
        UIUserInterfaceStyle(rawValue: UserDefaults.standard.integer(forKey: key)) ?? .light
    }
}

extension ThemesManager: ThemesManagerProtocol {        
    func apply(theme: UIUserInterfaceStyle, completion: @escaping (UIUserInterfaceStyle) -> Void) {
        UserDefaults.standard.set(theme.rawValue, forKey: key)
        completion(theme)
    }
}

