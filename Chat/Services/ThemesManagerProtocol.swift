import UIKit

protocol ThemesManagerProtocol: AnyObject {
    func apply(theme: UIUserInterfaceStyle, completion: @escaping (UIUserInterfaceStyle) -> Void)
}
