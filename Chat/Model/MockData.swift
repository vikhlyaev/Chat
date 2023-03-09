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
    ]
    
    var users: [User] {
        for (index, friend) in usersArray.enumerated() {
            if index % 2 == 0 {
                friend.isOnline = true
            }
            if index % 3 != 0 {
                friend.messages = [.init(text: "I've paid my dues, time after time", date: Date(), type: .sent),
                                   .init(text: "I've done my sentence, but committed no crime", date: Date(), type: .received),
                                   .init(text: "And bad mistakes I've made a few", date: Date(), type: .sent),
                                   .init(text: "I've had my share of sand kicked in my face, but I've come through", date: Date(), type: .received),
                                   .init(text: "And I need to go on and on, and on, and on", date: Date(), type: .received),
                                   .init(text: "We are the champions, my friends We are the champions, my friends We are the champions, my friends We are the champions, my friends", date: Date(), type: .sent),
                                   .init(text: "And we'll keep on fighting till the end", date: Date(), type: .received),
                                   .init(text: "We are the champions", date: Date(), type: .received),
                                   .init(text: "We are the champions", date: Date(), type: .sent),
                                   .init(text: "No time for losers", date: Date(), type: .received),
                                   .init(text: "'Cause, we are the champions of the world", date: Date(), type: .sent)
                ]
            }
        }
        return usersArray
    }
    
    private init() {}
}
