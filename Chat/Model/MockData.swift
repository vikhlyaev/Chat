import UIKit

final class MockData {
    static let shared = MockData()
    
    let user = User(name: "Anton Vikhlyaev", information: "iOS Developer, \nSterlitamak, Bashkortostan", withPhoto: nil)
    
    private let usersArray = [
        User(name: "Lucius Carson", information: "Android Developer", withPhoto: nil),
        User(name: "Werner Ball", information: "Economist", withPhotoString: "0"),
        User(name: "Bobette Dennis", information: "Lawyer", withPhoto: nil),
        User(name: "Milo Hull", information: "iOS Developer", withPhotoString: "1"),
        User(name: "Nolan Garner", information: "Marketing Manager", withPhotoString: "2"),
        User(name: "Kacy Brown", information: "Android Developer", withPhoto: nil),
        User(name: "Shemika Farrell", information: "Economist", withPhotoString: "3"),
        User(name: "Larae Jones", information: "Lawyer", withPhoto: nil),
        User(name: "Elza Hatfield", information: "iOS Developer", withPhotoString: "4"),
        User(name: "Johnie Espinoza", information: "Marketing Manager", withPhoto: nil),
        User(name: "Lucius Carson", information: "Android Developer", withPhoto: nil),
        User(name: "Werner Ball", information: "Economist", withPhotoString: "0"),
        User(name: "Bobette Dennis", information: "Lawyer", withPhoto: nil),
        User(name: "Milo Hull", information: "iOS Developer", withPhotoString: "1"),
        User(name: "Nolan Garner", information: "Marketing Manager", withPhotoString: "2"),
        User(name: "Kacy Brown", information: "Android Developer", withPhoto: nil),
        User(name: "Shemika Farrell", information: "Economist", withPhotoString: "3"),
        User(name: "Larae Jones", information: "Lawyer", withPhoto: nil),
        User(name: "Elza Hatfield", information: "iOS Developer", withPhotoString: "4"),
        User(name: "Johnie Espinoza", information: "Marketing Manager", withPhoto: nil),
        User(name: "Nolan Garner", information: "Marketing Manager", withPhotoString: "2"),
        User(name: "Kacy Brown", information: "Android Developer", withPhoto: nil),
        User(name: "Shemika Farrell", information: "Economist", withPhotoString: "3"),
        User(name: "Larae Jones", information: "Lawyer", withPhoto: nil),
        User(name: "Elza Hatfield", information: "iOS Developer", withPhotoString: "4"),
        User(name: "Johnie Espinoza", information: "Marketing Manager", withPhoto: nil),
        User(name: "Nolan Garner", information: "Marketing Manager", withPhotoString: "2"),
        User(name: "Kacy Brown", information: "Android Developer", withPhoto: nil),
        User(name: "Shemika Farrell", information: "Economist", withPhotoString: "3"),
        User(name: "Larae Jones", information: "Lawyer", withPhoto: nil),
        User(name: "Elza Hatfield", information: "iOS Developer", withPhotoString: "4"),
        User(name: "Johnie Espinoza", information: "Marketing Manager", withPhoto: nil)
    ]
    
    var users: [User] {
        for (index, friend) in usersArray.enumerated() {
            if index % 2 == 0 {
                friend.isOnline = true
            }
            if index % 3 != 0 {
                friend.messages = [.init(text: "We are the champions 🏆",
                                         date: Date(),
                                         type: .sent),
                                   .init(text: "I've paid my dues, time after time",
                                         date: Date("05.02.2023 12:48"),
                                         type: .sent),
                                   .init(text: "I've done my sentence, but committed no crime",
                                         date: Date("05.02.2023 12:46"),
                                         type: .received),
                                   .init(text: "And bad mistakes I've made a few",
                                         date: Date("05.02.2023 12:32"),
                                         type: .sent),
                                   .init(text: "I've had my share of sand kicked in my face, but I've come through",
                                         date: Date("04.02.2023 22:18"),
                                         type: .received),
                                   .init(text: "And I need to go on and on, and on, and on",
                                         date: Date("04.02.2023 22:01"),
                                         type: .received),
                                   .init(text: "We are the champions, my friends We are the champions, my friends We are the champions, my friends",
                                         date: Date("04.02.2023 21:52"),
                                         type: .sent),
                                   .init(text: "And we'll keep on fighting till the end",
                                         date: Date("04.02.2023 21:48"),
                                         type: .received),
                                   .init(text: "We are the champions",
                                         date: Date("04.02.2023 21:47"),
                                         type: .received),
                                   .init(text: "We are the champions",
                                         date: Date("04.02.2023 21:39"),
                                         type: .sent),
                                   .init(text: "No time for losers",
                                         date: Date("23.01.2023 00:01"),
                                         type: .received),
                                   .init(text: "'Cause, we are the champions of the world",
                                         date: Date("30.12.2022 23:38"),
                                         type: .sent),
                                   .init(text: "We are the champions 🏆",
                                         date: Date(),
                                         type: .sent),
                                   .init(text: "I've paid my dues, time after time",
                                         date: Date("29.12.2022 22:18"),
                                         type: .sent)
                ].reversed()
            }
            if index == 1 {
                friend.hasUnreadMessages = true
                friend.messages = [.init(text: "Hi! This is an unread message", date: Date("27.11.2022 08:10"), type: .received)]
            }
        }
        return usersArray
    }
    
    private init() {}
}
