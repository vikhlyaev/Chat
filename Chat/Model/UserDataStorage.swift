import Foundation

final class UserDataStorage {
    
    private static let userIDKey = "MyUserID"
    
    static var userID: String? {
        get {
            UserDefaults.standard.string(forKey: userIDKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userIDKey)
        }
    }
}
