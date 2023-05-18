import UIKit

final class ProfileCoordinator {
    let navigationController: UINavigationController
    private let moduleAssembly: ModuleAssembly
    
    init(navigationController: UINavigationController,
         moduleAssembly: ModuleAssembly) {
        self.navigationController = navigationController
        self.moduleAssembly = moduleAssembly
    }
}

// MARK: - Coordinator

extension ProfileCoordinator: Coordinator {
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

// MARK: - ProfileModuleOutput, ProfileEditModuleOutput

extension ProfileCoordinator: ProfileModuleOutput, ProfileEditModuleOutput {
    func moduleWantsToOpenPhotoSelection(withDelegate delegate: PhotoSelectionDelegate) {
        let vc = moduleAssembly.makePhotoSelectionModule(with: delegate)
        let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        window?.rootViewController?.present(vc, animated: true)
    }
    
    func moduleWantsToOpenProfileEdit(
        with profileModel: ProfileModel,
        transitioningDelegate: UIViewControllerTransitioningDelegate,
        delegate: ProfileEditDelegate
    ) {
        let vc = moduleAssembly.makeProfileEditModule(
            with: profileModel,
            moduleOutput: self,
            transitioningDelegate: transitioningDelegate,
            delegate: delegate
        )
        vc.modalPresentationStyle = .custom
        let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        window?.rootViewController?.present(vc, animated: true)
    }
}
