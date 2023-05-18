import UIKit

final class AppCoordinatorImpl {
    
    private weak var window: UIWindow?
    private let moduleAssembly: ModuleAssembly
    
    private lazy var tabBarController = TabBarController(
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
    
    init(moduleAssembly: ModuleAssembly) {
        self.moduleAssembly = moduleAssembly
    }
}

// MARK: - AppCoordinator

extension AppCoordinatorImpl: AppCoordinator {
    func start(in window: UIWindow) {
        let tabBarController = tabBarController
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }
}
