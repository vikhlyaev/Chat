import UIKit

final class SaveDataOperation: Operation {
    private lazy var dataManager: DataManagerProtocol = DataManager()
    private let data: Data
    private let type: DataType
    var error: DataManagerError?
    
    init(data: Data, type: DataType) {
        self.data = data
        self.type = type
        super.init()
    }
    
    override func main() {
        dataManager.write(data, as: type, completion: { [weak self] error in
            if let error = error {
                self?.error = error
            }
        })
    }
}
