import Foundation

final class UserDataStorage {
    
    private static let userIdKey = "MyUserId"
    
    static var userId: String? {
        get {
            UserDefaults.standard.string(forKey: userIdKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userIdKey)
        }
    }
}
