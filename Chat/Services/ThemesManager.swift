import UIKit

final class ThemesManager {
    private let application = UIApplication.shared
    var currentTheme: Theme?
    let key = "CurrentTheme"
}

extension ThemesManager: ThemesManagerProtocol {
    
    func loadTheme(completion: @escaping (Int) -> Void) {
        let currentThemeIndex = UserDefaults.standard.integer(forKey: key)
        apply(theme: Theme(rawValue: currentThemeIndex) ?? .day)
        completion(currentThemeIndex)
    }
    
    func saveTheme() {
        guard let currentTheme = currentTheme else { return }
        UserDefaults.standard.set(currentTheme.rawValue, forKey: key)
    }
    
    func apply(theme: Theme) {
        currentTheme = theme
        print(theme.title)
        print(theme.rawValue)
        
        // Setting UIView backgroundColor
        AppView.appearance()
            .backgroundColor = theme.backgroundColor
        ProfileView.appearance()
            .backgroundColor = theme.profileScreenBackgroundColor
        
        // Setting UITableView
        UITableView.appearance()
            .backgroundColor = theme.backgroundColor
        UITableView.appearance(whenContainedInInstancesOf: [SettingsView.self])
            .backgroundColor = theme.settingsScreenBackgroundColor
        UIView.appearance(whenContainedInInstancesOf: [ThemesCell.self])
            .backgroundColor = theme.settingsCellBackgroundColor
        UIView.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
            .tintColor = theme.backgroundColor
        UIView.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
            .backgroundColor = theme.backgroundColor
        ConversationsListHeader.appearance()
            .backgroundColor = theme.backgroundColor
        ConversationCell.appearance()
            .backgroundColor = theme.backgroundColor
        ConversationsHeader.appearance()
            .backgroundColor = theme.backgroundColor
        
        // Setting UILabel
        UILabel.appearance()
            .textColor = theme.textColor
        
        // Setting UINavigationBar
        let appBarAppearance = UINavigationBarAppearance()
        appBarAppearance.configureWithTransparentBackground()
        appBarAppearance.titleTextAttributes = [.foregroundColor: theme.textColor]
        appBarAppearance.largeTitleTextAttributes = [.foregroundColor: theme.textColor]
        appBarAppearance.backgroundColor = theme.backgroundColor
        
        UINavigationBar.appearance().standardAppearance = appBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = appBarAppearance
        UINavigationBar.appearance().compactAppearance = appBarAppearance
        
        // Setting tint color
        UIImageView.appearance(whenContainedInInstancesOf: [ConversationsListCell.self])
            .tintColor = theme.textColor
        
        // Setting separator color
        CustomSeparator.appearance(whenContainedInInstancesOf: [ConversationsListCell.self])
            .backgroundColor = theme.textColor
        
        // Setting custom nav bar
        CustomNavBar.appearance()
            .backgroundColor = theme.secondaryBackgroundColor
        
        WrapperView.appearance()
            .backgroundColor = theme.backgroundColor
        
        application.windows.reload()
        
        saveTheme()
    }
}

