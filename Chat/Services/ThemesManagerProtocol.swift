import Foundation

protocol ThemesManagerProtocol: AnyObject {
    func loadTheme()
    func saveTheme()
    func apply(theme: Theme)
}
