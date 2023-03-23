import UIKit

protocol ThemesManagerProtocol: AnyObject {
    func apply(theme: UIUserInterfaceStyle, completion: @escaping (UIUserInterfaceStyle) -> Void)
}

final class ThemesManager {
    private let key = "CurrentTheme"
    var currentTheme: UIUserInterfaceStyle {
        UIUserInterfaceStyle(rawValue: UserDefaults.standard.integer(forKey: key)) ?? .light
    }
}

// MARK: - ThemesManagerProtocol

extension ThemesManager: ThemesManagerProtocol {        
    func apply(theme: UIUserInterfaceStyle, completion: @escaping (UIUserInterfaceStyle) -> Void) {
        UserDefaults.standard.set(theme.rawValue, forKey: key)
        completion(theme)
    }
}

