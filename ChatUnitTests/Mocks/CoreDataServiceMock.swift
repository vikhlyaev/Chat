import Foundation
import CoreData
@testable import Chat

final class CoreDataServiceMock: CoreDataService {
    var invokedFetchProfile = false
    var invokedFetchProfileCount = 0
    var stubbedFetchProfileError: Error?
    var stubbedFetchProfileResult: [ProfileManagedObject]! = []

    func fetchProfile() throws -> [ProfileManagedObject] {
        invokedFetchProfile = true
        invokedFetchProfileCount += 1
        if let error = stubbedFetchProfileError {
            throw error
        }
        return stubbedFetchProfileResult
    }

    var invokedFetchChannels = false
    var invokedFetchChannelsCount = 0
    var stubbedFetchChannelsError: Error?
    var stubbedFetchChannelsResult: [ChannelManagedObject]! = []

    func fetchChannels() throws -> [ChannelManagedObject] {
        invokedFetchChannels = true
        invokedFetchChannelsCount += 1
        if let error = stubbedFetchChannelsError {
            throw error
        }
        return stubbedFetchChannelsResult
    }

    var invokedFetchMessages = false
    var invokedFetchMessagesCount = 0
    var invokedFetchMessagesParameters: (channelId: String, Void)?
    var invokedFetchMessagesParametersList = [(channelId: String, Void)]()
    var stubbedFetchMessagesError: Error?
    var stubbedFetchMessagesResult: [MessageManagedObject]! = []

    func fetchMessages(for channelId: String) throws -> [MessageManagedObject] {
        invokedFetchMessages = true
        invokedFetchMessagesCount += 1
        invokedFetchMessagesParameters = (channelId, ())
        invokedFetchMessagesParametersList.append((channelId, ()))
        if let error = stubbedFetchMessagesError {
            throw error
        }
        return stubbedFetchMessagesResult
    }

    var invokedUpdate = false
    var invokedUpdateCount = 0
    var stubbedUpdateBlockResult: (NSManagedObjectContext, Void)?

    func update(block: (NSManagedObjectContext) throws -> Void) {
        invokedUpdate = true
        invokedUpdateCount += 1
        if let result = stubbedUpdateBlockResult {
            try? block(result.0)
        }
    }
}
