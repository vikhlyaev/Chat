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
    
    static let nightBackgroundColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00)
    static let nightLightBackgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00)
    static let nightLabelColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let nightTintColor = UIColor(red: 0.00, green: 0.54, blue: 0.48, alpha: 1.00)
    
    
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
    
    var tintColor: UIColor {
        switch self {
        case .day:
            return .dayTintColor
        case .night:
            return .nightTintColor
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
