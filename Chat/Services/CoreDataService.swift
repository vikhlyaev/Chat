import Foundation
import CoreData
import OSLog

protocol CoreDataServiceProtocol: AnyObject {
    func fetchChannels() throws -> [ChannelManagedObject]
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
    func fetchChannels() throws -> [ChannelManagedObject] {
        defer { logger.info("\(String(describing: CoreDataService.self)): Successfully received") }
        let fetchRequest = ChannelManagedObject.fetchRequest()
        return try viewContext.fetch(fetchRequest)
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
