import UIKit

final class ChannelsCoordinator {
    let navigationController: UINavigationController
    private let moduleAssembly: ModuleAssembly
    
    init(navigationController: UINavigationController,
         moduleAssembly: ModuleAssembly) {
        self.navigationController = navigationController
        self.moduleAssembly = moduleAssembly
    }
}

// MARK: - Coordinator

extension ChannelsCoordinator: Coordinator {
    func start() {
        let vc = moduleAssembly.makeChannelsListModule(moduleOutput: self)
        vc.tabBarItem = UITabBarItem(
            title: "Channels",
            image: UIImage(systemName: "bubble.left.and.bubble.right"),
            tag: 0
        )
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - ChannelsListModuleOutput

extension ChannelsCoordinator: ChannelsListModuleOutput {
    func moduleWantsToOpenChannel(with channel: ChannelModel) {
        let vc = moduleAssembly.makeChannelModule(with: channel, and: self)
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - ChannelModuleOutput

extension ChannelsCoordinator: ChannelModuleOutput {
    func moduleWantsToOpenPhotoSelection(with delegate: PhotoSelectionDelegate) {
        let vc = moduleAssembly.makePhotoSelectionModule(with: delegate)
        let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        window?.rootViewController?.present(vc, animated: true)
    }
}
