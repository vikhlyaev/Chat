import UIKit

final class ThemesServiceImpl {
    private let key = "CurrentTheme"
    
    private let logService: LogService
    
    init(logService: LogService) {
        self.logService = logService
    }
}

// MARK: - ThemesService

extension ThemesServiceImpl: ThemesService {
    var currentTheme: UIUserInterfaceStyle {
        get {
            logService.success("Theme received")
            return UIUserInterfaceStyle(rawValue: UserDefaults.standard.integer(forKey: key)) ?? .light
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = currentTheme
            logService.success("Theme set")
        }
    }
}
