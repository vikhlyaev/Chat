import UIKit

extension UIApplication.State {
    var stringValue: String {
        switch self {
        case .active:
            return "Active"
        case .inactive:
            return "Inactive"
        case .background:
            return "Background"
        @unknown default:
            return "Not Running"
        }
    }
}
