import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let serviceAssembly: ServiceAssembly = ServiceAssemblyImpl()
        let moduleAssembly: ModuleAssembly = ModuleAssemblyImpl(serviceAssembly: serviceAssembly)
        
        let themesService = serviceAssembly.makeThemesService()
        window.overrideUserInterfaceStyle = themesService.currentTheme
        
        coordinator = AppCoordinator(moduleAssembly: moduleAssembly)
        coordinator?.start(in: window)
        return true
    }
}
