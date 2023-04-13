import Foundation
import TFSChatTransport
import OSLog

protocol DataSourceProtocol {
    func getChannels(completion: () -> Void) -> [ChannelModel]
    func saveChannelModel(with channelModel: ChannelModel)
    func deleteChannelModel(with channelModel: ChannelModel)
}

final class DataSource {
    private let coreDataService: CoreDataServiceProtocol = CoreDataService()
    
    private var logger: Logger {
        if ProcessInfo.processInfo.environment.keys.contains("COREDATA_LOGGING") {
            return Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "CoreDataLog")
        } else {
            return Logger(.disabled)
        }
    }
}

// MARK: - DataSourceProtocol

extension DataSource: DataSourceProtocol {
    
    // MARK: - CoreData Service methods
    
    func getChannels(completion: () -> Void) -> [ChannelModel] {
        defer { completion() }
        do {
            let channelManagedObjects = try coreDataService.fetchChannels()
            let channels: [ChannelModel] = channelManagedObjects.compactMap { channelManagerObject in
                guard
                    let id = channelManagerObject.id,
                    let name = channelManagerObject.name
                else {
                    return nil
                }
                let logoURL = channelManagerObject.logoURL
                let lastMessage = channelManagerObject.lastMessage
                let lastActivity = channelManagerObject.lastActivity
                logger.info("\(String(describing: DataSource.self)): Successfully received - Main Thread: \(Thread.isMainThread)")
                return ChannelModel(id: id,
                                    name: name,
                                    logoURL: logoURL,
                                    lastMessage: lastMessage,
                                    lastActivity: lastActivity)
            }
            return channels
        } catch {
            logger.error("\(String(describing: DataSource.self)): Error receiving channels - Main Thread: \(Thread.isMainThread) - Error: \(error)")
            return []
        }
    }
    
    func saveChannelModel(with channelModel: ChannelModel) {
        coreDataService.save { context in
            let channelManagedObject = ChannelManagedObject(context: context)
            channelManagedObject.id = channelModel.id
            channelManagedObject.name = channelModel.name
            channelManagedObject.logoURL = channelModel.logoURL
            channelManagedObject.lastMessage = channelModel.lastMessage
            channelManagedObject.lastActivity = channelModel.lastActivity
        }
    }
    
    func deleteChannelModel(with channelModel: ChannelModel) {
        coreDataService.save { context in
            let fetchRequest = ChannelManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", channelModel.id as CVarArg)
            do {
                guard let channelManagedObject = try context.fetch(fetchRequest).first else { return }
                context.delete(channelManagedObject)
            } catch {
                logger.error("\(String(describing: DataSource.self)): Delete channel error - Main Thread: \(Thread.isMainThread) - Error: \(error)")
            }
        }
    }
}
