import Foundation
import CoreData

protocol CoreDataService {
    func fetchProfile() throws -> [ProfileManagedObject]
    func fetchChannels() throws -> [ChannelManagedObject]
    func fetchMessages(for channelId: String) throws -> [MessageManagedObject]
    func update(block: (NSManagedObjectContext) throws -> Void)
}
