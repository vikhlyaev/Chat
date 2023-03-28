import UIKit

struct ProfileViewModel {
    var name: String?
    var information: String?
    var photo: UIImage?
    
    subscript(index: Int) -> String? {
        switch index {
        case 0: return name
        case 1: return information
        default: return nil
        }
    }
}
