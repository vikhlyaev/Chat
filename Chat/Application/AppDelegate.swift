import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let tabBarController = TabBarController()
        window?.rootViewController = tabBarController
        window?.overrideUserInterfaceStyle = ThemesManager().currentTheme
        window?.makeKeyAndVisible()
        return true
    }
}
