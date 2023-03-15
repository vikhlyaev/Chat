import UIKit

enum Theme: ThemeProtocol {
    case day
    case night
    
    var title: String {
        switch self {
        case .day:
            return "Day"
        case .night:
            return "Night"
        }
    }
    
    // Colors scheme
    var backgroundColor: UIColor {
        switch self {
        case .day:
            return .dayBackgroundColor
        case .night:
            return .nightBackgroundColor
        }
    }
    
    var secondaryBackgroundColor: UIColor {
        switch self {
        case .day:
            return .daySecondaryBackgroundColor
        case .night:
            return .nightSecondaryBackgroundColor
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .day:
            return .dayLabelColor
        case .night:
            return .nightLabelColor
        }
    }
}
