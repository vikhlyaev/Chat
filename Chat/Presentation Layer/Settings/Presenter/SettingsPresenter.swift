import UIKit

final class SettingsPresenter {
    
    weak var viewInput: SettingsViewInput?
    
    private let themesService: ThemesService
    
    init(themesService: ThemesService) {
        self.themesService = themesService
    }
}

extension SettingsPresenter: SettingsViewOutput {
    func viewIsReady() {
        let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        window?.overrideUserInterfaceStyle = currentTheme
        
        viewInput?.setInitialState(currentTheme: currentTheme)
    }
    
    var currentTheme: UIUserInterfaceStyle {
        themesService.currentTheme
    }
    
    func didButtonTapped(theme: UIUserInterfaceStyle) {
        themesService.currentTheme = theme
    }
}
