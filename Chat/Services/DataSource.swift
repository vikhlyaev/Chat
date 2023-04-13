import Foundation
import TFSChatTransport

protocol DataSourceProtocol {
    func getChannels() -> [ChannelModel]
    func saveChannelModel(with channelModel: ChannelModel)
}

final class DataSource {
    private let coreDataService: CoreDataServiceProtocol = CoreDataService()
}

// MARK: - DataSourceProtocol

extension DataSource: DataSourceProtocol {
    
    // MARK: - CoreData Service methods
    
    func getChannels() -> [ChannelModel] {
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
                return ChannelModel(id: id,
                                    name: name,
                                    logoURL: logoURL,
                                    lastMessage: lastMessage,
                                    lastActivity: lastActivity)
            }
            return channels
        } catch {
            print(error)
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
}
