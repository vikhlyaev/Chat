import Foundation
import CoreData

final class CoreDataServiceImpl {
    private lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Chat")
        container.loadPersistentStores { [weak self] _, error in
            if let error = error as NSError? {
                fatalError("Failed to create persistant container")
            }
        }
        return container
    }()
    
    private lazy var viewContext: NSManagedObjectContext = {
        persistantContainer.viewContext
    }()
    
}

extension CoreDataServiceImpl: CoreDataService {
    
    func fetchProfile() throws -> [ProfileManagedObject] {
        let fetchRequest = ProfileManagedObject.fetchRequest()
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            fatalError("Error fetching profile")
        }
    }
    
    func fetchChannels() throws -> [ChannelManagedObject] {
        let fetchRequest = ChannelManagedObject.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "lastActivity", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            fatalError("Error fetching channels")
        }
    }
    
    func fetchMessages(for channelId: String) throws -> [MessageManagedObject] {
        let fetchRequest = ChannelManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", channelId as CVarArg)
        guard
            let channelManagedObject = try viewContext.fetch(fetchRequest).first,
            let messagesManagedObjects = channelManagedObject.messages?.array as? [MessageManagedObject]
        else {
            fatalError("Error fetching messages")
        }
        return messagesManagedObjects
    }
    
    func update(block: (NSManagedObjectContext) throws -> Void) {
        let backgroundContext = persistantContainer.newBackgroundContext()
        backgroundContext.performAndWait {
            do {
                try block(backgroundContext)
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }
            } catch {
                fatalError("Data not updated")
            }
        }
    }
}
