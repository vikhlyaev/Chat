import UIKit

final class TabBarController: UITabBarController {
    
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
        
        let dataSource: [Tabs] = [.channels, .settings, .profile]
        
        viewControllers = dataSource.map {
            switch $0 {
            case .channels:
                return UINavigationController(rootViewController: ChannelsListViewController())
            case .settings:
                let themesService = ServiceAssembly.shared.makeThemesService()
                let presenter = SettingsPresenter(themesService: themesService)
                let settingsViewController = SettingsViewController(output: presenter)
                presenter.viewInput = settingsViewController
                return UINavigationController(rootViewController: settingsViewController)
            case .profile:
                let profileService = ServiceAssembly.shared.makeProfileService()
                let presenter = ProfilePresenter(profileService: profileService)
                let profileViewController = ProfileViewController(output: presenter)
                presenter.viewInput = profileViewController
                return UINavigationController(rootViewController: profileViewController)
            }
        }
        
        viewControllers?.enumerated().forEach {
            $1.tabBarItem.title = dataSource[$0].titleTabBar
            $1.tabBarItem.image = UIImage(systemName: dataSource[$0].iconName)
            $1.tabBarItem.tag = $0
        }
    }
}

enum Tabs: Int {
    case channels
    case settings
    case profile
    
    var titleTabBar: String {
        switch self {
        case .channels:
            return "Channels"
        case .settings:
            return "Settings"
        case .profile:
            return "Profile"
        }
    }
    
    var iconName: String {
        switch self {
        case .channels:
            return "bubble.left.and.bubble.right"
        case .settings:
            return "gear"
        case .profile:
            return "person.crop.circle"
        }
    }
}
