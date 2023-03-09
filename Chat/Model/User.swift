import UIKit

final class User {
    let name: String
    var information: String?
    var photo: UIImage?
    var isOnline: Bool = false
    var hasUnreadMessages: Bool = false
    var messages: [Message]?
    
    init(name: String, information: String? = nil, withPhoto photoName: String? = nil) {
        self.name = name
        self.information = information ?? nil
        // временная реализация со строкой для моков
        if let photoName = photoName {
            guard let photo = UIImage(named: photoName) else { return }
            self.photo = photo
        } else {
            self.photo = UIImage.makeRandomAvatar(with: name)
        }
    }
    
    init(name: String, information: String? = nil, withPhoto photo: UIImage? = nil) {
        self.name = name
        self.information = information ?? nil
        self.photo = photo ?? UIImage.makeRandomAvatar(with: name)
    }
}
