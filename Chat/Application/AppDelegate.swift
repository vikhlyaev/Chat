import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let serviceAssembly = ServiceAssembly()
        let moduleAssembly = ModuleAssembly(serviceAssembly: serviceAssembly)
        
        let themesService = serviceAssembly.makeThemesService()
        window.overrideUserInterfaceStyle = themesService.currentTheme
        
        let tabBarController = TabBarController(
            channelsCoordinator:
                ChannelsCoordinator(
                    navigationController: UINavigationController(),
                    moduleAssembly: moduleAssembly
                ),
            settingsCoordinator:
                SettingsCoordinator(
                    navigationController: UINavigationController(),
                    moduleAssembly: moduleAssembly
                ),
            profileCoordinator:
                ProfileCoordinator(
                    navigationController: UINavigationController(),
                    moduleAssembly: moduleAssembly
                )
        )
        
        coordinator = AppCoordinator(tabBarController: tabBarController)
        coordinator?.start(in: window)
        return true
    }
}
