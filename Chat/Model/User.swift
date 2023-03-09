import UIKit

final class User {
    let name: String
    var information: String?
    var photo: UIImage
    var isOnline: Bool = false
    var hasUnreadMessages: Bool = false
    var messages: [Message]?
    var sortedMessage: [SortedMessages]? {
        guard let messages = messages else { return nil }
        var sortedMessages: [SortedMessages] = []
        for (date, messages) in messages.daySorted {
            sortedMessages.append(SortedMessages(date: date, messages: messages))
        }
        return sortedMessages.sorted { $0.date < $1.date }
    }
    
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

struct SortedMessages {
    let date: Date
    let messages: [Message]
}
