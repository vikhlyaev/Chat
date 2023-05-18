import UIKit

final class SettingsCoordinatorImpl {
    let navigationController: UINavigationController
    private let moduleAssembly: ModuleAssembly
    
    init(navigationController: UINavigationController,
         moduleAssembly: ModuleAssembly) {
        self.navigationController = navigationController
        self.moduleAssembly = moduleAssembly
    }
}

// MARK: - Coordinator

extension SettingsCoordinatorImpl: Coordinator {
    func start() {
        let vc = moduleAssembly.makeSettingsModule()
        vc.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear"),
            tag: 1
        )
        navigationController.pushViewController(vc, animated: true)
    }
}
