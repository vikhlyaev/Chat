import Foundation
import KeychainAccess

final class UserDataStorage {
    
    private static let userIDKey = "MyUserID"
    private static let keychain = Keychain(service: "ru.vikhlyaev.Chat")
    
    static var userID: String? {
        get {
            keychain[userIDKey]
        }
        set {
            keychain[userIDKey] = newValue
        }
    }
}
