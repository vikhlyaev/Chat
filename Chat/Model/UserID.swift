import Foundation

final class UserID {
    
    private static let key = "MyUserID"
    
    static var value: String? {
        get {
            UserDefaults.standard.string(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
