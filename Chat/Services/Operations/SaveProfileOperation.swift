import UIKit

final class SaveProfileOperation: Operation {
    private lazy var dataManager: DataManagerProtocol = DataManager()
    var profile: ProfileViewModel
    var error: DataManagerError?
    
    init(profile: ProfileViewModel) {
        self.profile = profile
    }
    
    override func main() {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 3
        operationQueue.qualityOfService = .userInitiated
        
        operationQueue.addOperation { [weak self] in
            if let name = self?.profile.name?.toData() {
                self?.dataManager.write(name, as: .name, completion: { [weak self] error in
                    if let error = error {
                        self?.error = error
                    }
                })
            }
        }
        
        operationQueue.addOperation { [weak self] in
            if let information = self?.profile.information?.toData() {
                self?.dataManager.write(information, as: .information, completion: { [weak self] error in
                    if let error = error {
                        self?.error = error
                    }
                })
            }
        }
        
        operationQueue.addOperation { [weak self] in
            if let photo = self?.profile.photo?.pngData() {
                self?.dataManager.write(photo, as: .photo, completion: { [weak self] error in
                    if let error = error {
                        self?.error = error
                    }
                })
            }
        }
    }
}
