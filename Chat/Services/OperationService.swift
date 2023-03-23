import Foundation

final class OperationService: ConcurrencyServiceProtocol {
    func loadProfile(completion: @escaping (Result<ProfileViewModel, DataManagerError>) -> Void) {
        let loadProfileOperation = LoadProfileOperation()
        loadProfileOperation.qualityOfService = .userInitiated
        loadProfileOperation.completionBlock = {
            OperationQueue.main.addOperation {
                if let profile = loadProfileOperation.profile {
                    completion(.success(profile))
                } else {
                    completion(.failure(loadProfileOperation.error ?? .writeFailure))
                }
            }
        }
        OperationQueue().addOperation(loadProfileOperation)
    }
    
    func saveProfile(profile: ProfileViewModel, completion: @escaping (DataManagerError?) -> Void) {
        let saveProfileOperation = SaveProfileOperation(profile: profile)
        saveProfileOperation.qualityOfService = .userInitiated
        saveProfileOperation.completionBlock = {
            OperationQueue.main.addOperation {
                if let error = saveProfileOperation.error {
                    completion(error)
                }
            }
        }
    }
    
    func saveData(_ data: Data, as type: DataType, completion: @escaping (DataManagerError?) -> Void) {
        let saveDataOperation = SaveDataOperation(data: data, type: type)
        saveDataOperation.qualityOfService = .userInitiated
        saveDataOperation.completionBlock = {
            OperationQueue.main.addOperation {
                if let error = saveDataOperation.error {
                    completion(error)
                }
            }
        }
    }
}
