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
    
    private var currentState: UIApplication.State {
        return UIApplication.shared.applicationState
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        logger.info("Application moved from Not Running to \(self.currentState.stringValue): \(#function)")
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
        logger.info("Application moved from \(self.currentState.stringValue) to \(UIApplication.State.inactive.stringValue): \(#function)")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        logger.info("Application moved from \(UIApplication.State.inactive.stringValue) to \(self.currentState.stringValue): \(#function)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        logger.info("Application moved from \(self.currentState.stringValue) to \(UIApplication.State.inactive.stringValue): \(#function)")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        logger.info("Application moved from \(UIApplication.State.inactive.stringValue) to \(self.currentState.stringValue): \(#function)")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        logger.info("Application moved from \(self.currentState.stringValue) to Not Running: \(#function)")
    }

}

