import Foundation

protocol ThemesManagerProtocol: AnyObject {
    func loadTheme(completion: @escaping (Int) -> Void)
    func saveTheme()
    func apply(theme: Theme)
}
