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
    func moduleWantsToOpenPhotoSelection(with delegate: PhotoSelectionDelegate) {
        let vc = moduleAssembly.makePhotoSelectionModule(with: delegate)
        let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        window?.rootViewController?.present(vc, animated: true)
    }
    
    func moduleWantsToOpenProfileEdit(with transitioningDelegate: UIViewControllerTransitioningDelegate) {
        let vc = moduleAssembly.makeProfileEditModule(with: transitioningDelegate)
        vc.modalPresentationStyle = .custom
        let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        window?.rootViewController?.present(vc, animated: true)
    }
}
