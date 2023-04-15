import Foundation
import CoreData
import OSLog

protocol CoreDataServiceProtocol: AnyObject {
    func fetchChannels() throws -> [ChannelManagedObject]
    func fetchMessages(for channelId: String) throws -> [MessageManagedObject]
    func fetchResultController(entityName: String, sortName: String) -> NSFetchedResultsController<NSFetchRequestResult>
    func save(block: (NSManagedObjectContext) throws -> Void)
}

final class CoreDataService {
    private var logger: Logger {
        if ProcessInfo.processInfo.environment.keys.contains("COREDATA_LOGGING") {
            return Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "CoreDataLog")
        } else {
            return Logger(.disabled)
        }
    }
    
    private lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Chat")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Error: \(error)")
            }
        }
        return container
    }()
    
    private lazy var viewContext: NSManagedObjectContext = {
        persistantContainer.viewContext
    }()
}

// MARK: - CoreDataServiceProtocol

extension CoreDataService: CoreDataServiceProtocol {
    
    func fetchResultController(entityName: String, sortName: String) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: sortName, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: fetchRequest,
                                          managedObjectContext: viewContext,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }
    
    func fetchChannels() throws -> [ChannelManagedObject] {
        let fetchRequest = ChannelManagedObject.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastActivity", ascending: false)]
        return try viewContext.fetch(fetchRequest)
    }
    
    func fetchMessages(for channelId: String) throws -> [MessageManagedObject] {
        let fetchRequest = ChannelManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", channelId as CVarArg)
        guard
            let channelManagedObject = try viewContext.fetch(fetchRequest).first,
            let messagesManagedObjects = channelManagedObject.messages?.array as? [MessageManagedObject]
        else {
            return []
        }
        return messagesManagedObjects
    }
    
    func save(block: (NSManagedObjectContext) throws -> Void) {
        let backgroundContext = persistantContainer.newBackgroundContext()
        backgroundContext.performAndWait {
            do {
                try block(backgroundContext)
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }
                logger.info("\(String(describing: CoreDataService.self)): Successfully saved")
            } catch {
                logger.error("\(String(describing: CoreDataService.self)): Saving error: \(error)")
            }
        }
    }
}

struct Constants {
    struct CoreData {
        static let channelEntityName = "ChannelManagedObject"
        static let messageEntityName = "MessageManagedObject"
        static let channelSortName = "lastActivity"
    }
}
