import UIKit

final class ProfileCoordinator {
    
    let navigationController: UINavigationController
    private let moduleAssembly: ModuleAssembly
    
    init(navigationController: UINavigationController,
         moduleAssembly: ModuleAssembly) {
        self.navigationController = navigationController
        self.moduleAssembly = moduleAssembly
    }
    
    func start() {
        let vc = moduleAssembly.makeProfileModule(moduleOutput: self)
        vc.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.crop.circle"),
            tag: 2
        )
        navigationController.pushViewController(vc, animated: true)
    }
}

extension ProfileCoordinator: ProfileModuleOutput {
    func moduleWantsToOpenPhotoSelection() {
        let vc = moduleAssembly.makePhotoSelectionModule()
        let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        window?.rootViewController?.present(vc, animated: true)
    }
}
