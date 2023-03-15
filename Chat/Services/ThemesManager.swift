import UIKit

final class ThemesManager {
    private let application = UIApplication.shared
    private var currentTheme: Theme?
}

extension ThemesManager: ThemesManagerProtocol {
    func loadTheme() {
        
    }
    
    func saveTheme() {
        
    }
    
    func apply(theme: Theme) {
        currentTheme = theme
        
        print(theme.title)
        
        AppView.appearance()
            .backgroundColor = theme.backgroundColor
        
        CustomNavBar.appearance(whenContainedInInstancesOf: [AppView.self])
            .backgroundColor = theme.secondaryBackgroundColor
        
        CustomSeparator.appearance(whenContainedInInstancesOf: [ConversationsListCell.self])
            .backgroundColor = theme.textColor
        
        
        // Setting UITableView
        UITableView.appearance().backgroundColor = theme.backgroundColor
        UIView.appearance(whenContainedInInstancesOf: [ThemesCell.self]).backgroundColor = theme.secondaryBackgroundColor
        UIView.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).tintColor = theme.backgroundColor
        UIView.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).backgroundColor = theme.backgroundColor
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = theme.textColor
        
        // Setting UILabel
        UILabel.appearance().textColor = theme.textColor
        
        // Setting UINavigationBar
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        navigationBarAppearance.backgroundColor = theme.backgroundColor
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: theme.textColor]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: theme.textColor]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        
        application.windows.reload()
    }
}

