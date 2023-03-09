import UIKit

final class User {
    let name: String
    var information: String?
    var photo: UIImage
    var isOnline: Bool = false
    var hasUnreadMessages: Bool = false
    var messages: [Message]?
    
    // временная реализация со строкой для моков
    init(name: String, information: String? = nil, withPhotoString photoName: String) {
        self.name = name
        self.information = information ?? nil
        self.photo = UIImage(named: photoName) ?? UIImage.makeRandomAvatar(with: name)
    }
    
    init(name: String, information: String? = nil, withPhoto photo: UIImage? = nil) {
        self.name = name
        self.information = information ?? nil
        self.photo = photo ?? UIImage.makeRandomAvatar(with: name)
    }
}
