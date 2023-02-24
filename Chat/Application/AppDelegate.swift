import UIKit
import OSLog

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var logger: Logger {
        if ProcessInfo.processInfo.environment.keys.contains("LOGGING") {
            return Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "AppLifeCycle")
        } else {
            return Logger(.disabled)
        }
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        logger.info("Application moved from Not Running to Inactive: \(#function)")
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController(rootViewController: ChatViewController())
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        logger.info("Application moved from Background to Inactive: \(#function)")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        logger.info("Application moved from Inactive to Active: \(#function)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        logger.info("Application moved from Active to Inactive: \(#function)")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        logger.info("Application moved from Inactive to Background: \(#function)")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        logger.info("Application moved from Background to Not Running: \(#function)")
    }

}

