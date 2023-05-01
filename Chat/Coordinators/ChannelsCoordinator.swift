import UIKit

final class ChannelsCoordinator {
    
    let navigationController: UINavigationController
    private let moduleAssembly: ModuleAssembly
    
    init(navigationController: UINavigationController,
         moduleAssembly: ModuleAssembly) {
        self.navigationController = navigationController
        self.moduleAssembly = moduleAssembly
    }
    
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

extension ChannelsCoordinator: ChannelsListModuleOutput {
    func moduleWantsToOpenChannel(with channel: ChannelModel) {
        let vc = moduleAssembly.makeChannelModule(with: channel)
        navigationController.pushViewController(vc, animated: true)
    }
}
