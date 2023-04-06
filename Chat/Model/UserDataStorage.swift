import Foundation

final class UserDataStorage {
    
    private static let userIDKey = "MyUserID"
    private static let nameKey = "MyName"
    
    static var userID: String? {
        get {
            UserDefaults.standard.string(forKey: userIDKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userIDKey)
        }
    }
    
    static var userName: String? {
        get {
            UserDefaults.standard.string(forKey: nameKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: nameKey)
        }
    }
}
