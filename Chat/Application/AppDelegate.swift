import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController(rootViewController: ConversationsListViewController())
        window?.rootViewController = navigationController
        window?.overrideUserInterfaceStyle = .light
        window?.makeKeyAndVisible()
        
        ThemesManager().loadTheme { [ weak self ] themeIndex in
            guard let theme = Theme(rawValue: themeIndex) else {
                self?.window?.overrideUserInterfaceStyle = .light
                return
            }
            switch theme {
            case .day:
                self?.window?.overrideUserInterfaceStyle = .light
            case .night:
                self?.window?.overrideUserInterfaceStyle = .dark
            }
        }
        
        return true
    }
}

