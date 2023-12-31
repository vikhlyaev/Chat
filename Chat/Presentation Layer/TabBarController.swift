import UIKit

final class TabBarController: UITabBarController {
    
    private let channelsCoordinator: Coordinator
    private let settingsCoordinator: Coordinator
    private let profileCoordinator: Coordinator
    
    init(channelsCoordinator: Coordinator,
         settingsCoordinator: Coordinator,
         profileCoordinator: Coordinator) {
        self.channelsCoordinator = channelsCoordinator
        self.settingsCoordinator = settingsCoordinator
        self.profileCoordinator = profileCoordinator
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let tabBarApperance = UITabBarAppearance()
        tabBarApperance.configureWithOpaqueBackground()
        tabBarApperance.backgroundColor = .systemGray6
        UITabBar.appearance().standardAppearance = tabBarApperance

        tabBar.tintColor = .systemBlue
        tabBar.barTintColor = .systemGray
        tabBar.backgroundColor = .systemGray6
        
        tabBar.layer.borderColor = UIColor.separator.cgColor
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.masksToBounds = true
        
        channelsCoordinator.start()
        settingsCoordinator.start()
        profileCoordinator.start()
        
        viewControllers = [
            channelsCoordinator.navigationController,
            settingsCoordinator.navigationController,
            profileCoordinator.navigationController
        ]
    }
}
