import Foundation
import CoreData
import OSLog

protocol CoreDataServiceProtocol {
    func fetchChannels() throws -> [ChannelManagedObject]
    func fetchMessages(for channelId: String) throws -> [MessageManagedObject]
    func update(block: (NSManagedObjectContext) throws -> Void)
}

final class CoreDataService {
    
    private var logger: Logger {
        if ProcessInfo.processInfo.environment.keys.contains("COREDATA_LOG") {
            return Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "CoreDataLog")
        } else {
            return Logger(.disabled)
        }
    }
    
    private lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Chat")
        container.loadPersistentStores { [weak self] _, error in
            if let error = error as NSError? {
                self?.logger.error("🔴 Failed to create persistant container")
                fatalError()
            }
        }
        return container
    }()
    
    private lazy var viewContext: NSManagedObjectContext = {
        persistantContainer.viewContext
    }()
}

extension CoreDataService: CoreDataServiceProtocol {
    
    func fetchChannels() throws -> [ChannelManagedObject] {
        let fetchRequest = ChannelManagedObject.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "lastActivity", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            logger.info("🟢 Channels fetching successfully")
            return try viewContext.fetch(fetchRequest)
        } catch {
            logger.error("🔴 Error fetching channels")
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
            logger.error("🔴 Error fetching messages")
            fatalError()
        }
        logger.info("🟢 Messages fetching successfully")
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
                logger.info("🟢 Updating successfully")
            } catch {
                logger.error("🔴 Updating error: \(error)")
            }
        }
    }
}
