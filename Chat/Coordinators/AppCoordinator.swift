import UIKit

final class AppCoordinator {
    
    private weak var window: UIWindow?
    private let tabBarController: TabBarController
    
    init(tabBarController: TabBarController) {
        self.tabBarController = tabBarController
    }
    
    func start(in window: UIWindow) {
        let tabBarController = tabBarController
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }
}
