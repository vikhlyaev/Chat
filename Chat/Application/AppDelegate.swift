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
        logger.info("Application moved from Not Running to \(application.applicationState.stringValue): \(#function)")
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
        logger.info("Application moved from \(application.applicationState.stringValue) to \(UIApplication.State.inactive.stringValue): \(#function)")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        logger.info("Application moved from \(UIApplication.State.inactive.stringValue) to \(application.applicationState.stringValue): \(#function)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        logger.info("Application moved from \(application.applicationState.stringValue) to \(UIApplication.State.inactive.stringValue): \(#function)")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        logger.info("Application moved from \(UIApplication.State.inactive.stringValue) to \(application.applicationState.stringValue): \(#function)")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        logger.info("Application moved from \(application.applicationState.stringValue) to Not Running: \(#function)")
    }

}

