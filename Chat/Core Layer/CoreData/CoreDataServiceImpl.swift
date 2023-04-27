import Foundation
import CoreData

final class CoreDataServiceImpl {
    
    private var logService: LogService
    
    init(logService: LogService) {
        self.logService = logService
    }
    
    private lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Chat")
        container.loadPersistentStores { [weak self] _, error in
            if let error = error as NSError? {
                self?.logService.error("Failed to create persistant container")
                fatalError()
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
            logService.success("Profile fetching successfully")
            return try viewContext.fetch(fetchRequest)
        } catch {
            logService.error("Error fetching profile")
            fatalError()
        }
    }
    
    func fetchChannels() throws -> [ChannelManagedObject] {
        let fetchRequest = ChannelManagedObject.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "lastActivity", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            logService.success("Channels fetching successfully")
            return try viewContext.fetch(fetchRequest)
        } catch {
            logService.error("Error fetching channels")
            fatalError()
        }
    }
    
    func fetchMessages(for channelId: String) throws -> [MessageManagedObject] {
        let fetchRequest = ChannelManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", channelId as CVarArg)
        guard
            let channelManagedObject = try viewContext.fetch(fetchRequest).first,
            let messagesManagedObjects = channelManagedObject.messages?.array as? [MessageManagedObject]
        else {
            logService.error("Error fetching messages")
            fatalError()
        }
        logService.success("Messages fetching successfully")
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
                logService.success("Updating successfully")
            } catch {
                logService.error("Updating error: \(error)")
            }
        }
    }
    
}
