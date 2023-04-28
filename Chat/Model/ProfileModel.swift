import UIKit

struct ProfileModel: Codable {
    let id = UUID()
    var name: String?
    var information: String?
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
