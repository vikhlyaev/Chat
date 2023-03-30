import UIKit

struct ProfileViewModel: Codable {
    var name = ""
    var information = ""
    var photo: UIImage?
    
    private enum CodingKeys: String, CodingKey {
       case name
       case information
   }
    
    subscript(index: Int) -> String? {
        switch index {
        case 0: return name
        case 1: return information
        default: return nil
        }
    }
}
