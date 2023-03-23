import UIKit

final class SaveDataOperation: Operation {
    private lazy var dataManager: DataManagerProtocol = DataManager()
    private let data: Data
    private let type: DataType
    var error: DataManagerError?
    
    init(data: Data, type: DataType) {
        self.data = data
        self.type = type
    }
    
    override func main() {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInitiated
        operationQueue.addOperation { [weak self] in
            guard let self = self else { return }
            self.dataManager.write(self.data, as: self.type, completion: { [weak self] error in
                if let error = error {
                    self?.error = error
                }
            })
        }
    }
}
