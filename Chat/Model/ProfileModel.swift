import UIKit

struct ProfileModel {
    var id: String?
    var name: String?
    var information: String?
    var photo: UIImage?
    
    init(id: String? = nil, name: String? = nil, information: String? = nil, photo: UIImage? = nil) {
        self.id = id
        self.name = name
        self.information = information
        self.photo = photo
    }
    
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
