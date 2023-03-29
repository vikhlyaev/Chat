import UIKit

struct ProfileViewModel: Equatable {
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
    
    static func ==(lhs: ProfileViewModel, rhs: ProfileViewModel) -> Bool {
        lhs.name == rhs.name && lhs.information == rhs.information && lhs.photo == rhs.photo
    }
}
