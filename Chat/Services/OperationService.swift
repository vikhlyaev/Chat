import Foundation

final class OperationService: ConcurrencyServiceProtocol {
    func loadProfile(completion: @escaping (Result<ProfileViewModel, DataManagerError>) -> Void) {
        let loadProfileOperation = LoadProfileOperation()
        loadProfileOperation.completionBlock = {
            OperationQueue.main.addOperation {
                if let profile = loadProfileOperation.profile {
                    completion(.success(profile))
                } else {
                    completion(.failure(loadProfileOperation.error ?? .writeFailure))
                }
            }
        }
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        queue.addOperation(loadProfileOperation)
    }
    
    func saveProfile(profile: ProfileViewModel, completion: @escaping (DataManagerError?) -> Void) {
        let saveProfileOperation = SaveProfileOperation(profile: profile)
        saveProfileOperation.completionBlock = {
            OperationQueue.main.addOperation {
                if let error = saveProfileOperation.error {
                    completion(error)
                }
            }
        }
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        queue.addOperation(saveProfileOperation)
    }
    
    func saveData(_ data: Data, as type: DataType, completion: @escaping (DataManagerError?) -> Void) {
        let saveDataOperation = SaveDataOperation(data: data, type: type)
        saveDataOperation.completionBlock = {
            OperationQueue.main.addOperation {
                if let error = saveDataOperation.error {
                    completion(error)
                }
            }
        }
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 3
        queue.addOperation(saveDataOperation)
    }
}
