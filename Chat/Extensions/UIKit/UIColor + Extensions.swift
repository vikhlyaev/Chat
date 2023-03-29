import UIKit

extension UIColor {
    static let appGreen = UIColor(red: 0.188, green: 0.82, blue: 0.345, alpha: 1)
    static var appBubbleSent: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .light ?
            UIColor(red: 0.27, green: 0.54, blue: 0.97, alpha: 1.00) :
            UIColor(red: 0.188, green: 0.82, blue: 0.345, alpha: 1.00)
        }
    }
    static var appBubbleReceived: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .light ?
            UIColor(red: 0.91, green: 0.91, blue: 0.92, alpha: 1.00) :
            UIColor(red: 0.15, green: 0.15, blue: 0.16, alpha: 1.00)
        }
    }
    static var appBubbleTextSent: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .light ?
            UIColor.white :
            UIColor.white
        }
    }
    static var appBubbleTextReceived: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .light ?
            UIColor.black :
            UIColor.white
        }
    }
}
