import UIKit

final class SettingsPresenter {
    weak var viewInput: SettingsViewInput?
    private let themesService: ThemesService
    
    init(themesService: ThemesService) {
        self.themesService = themesService
    }
}

extension SettingsPresenter: SettingsViewOutput {
    var currentTheme: UIUserInterfaceStyle {
        themesService.currentTheme
    }
    
    func didButtonTapped(theme: UIUserInterfaceStyle) {
        themesService.currentTheme = theme
    }
}
