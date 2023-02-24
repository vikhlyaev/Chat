import UIKit

final class User {
    var name: String
    var position: String
    var city: String
    
    var photo: UIImage?
    
    var initials: String {
        name.split(separator: " ").compactMap { String($0).first }.map { String($0) }.joined()
    }
    
    init(name: String, position: String, city: String) {
        self.name = name
        self.position = position
        self.city = city
    }
}
