import UIKit

enum Theme: Int, ThemeProtocol {
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
    
    var profileScreenBackgroundColor: UIColor {
        switch self {
        case .day:
            return .dayBackgroundColor
        case .night:
            return .nightSecondaryBackgroundColor
        }
    }
    
    var settingsScreenBackgroundColor: UIColor {
        switch self {
        case .day:
            return .daySecondaryBackgroundColor
        case .night:
            return .nightBackgroundColor
        }
    }
    
    var settingsCellBackgroundColor: UIColor {
        switch self {
        case .day:
            return .dayBackgroundColor
        case .night:
            return .nightSecondaryBackgroundColor
        }
    }
}
