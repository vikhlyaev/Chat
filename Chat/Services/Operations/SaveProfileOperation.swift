import UIKit

final class SaveProfileOperation: Operation {
    private lazy var dataManager: DataManagerProtocol = DataManager()
    var profile: ProfileViewModel
    var error: DataManagerError?
    
    init(profile: ProfileViewModel) {
        self.profile = profile
        super.init()
    }
    
    override func main() {
        if let name = profile.name?.toData() {
            dataManager.write(name, as: .name, completion: { [weak self] error in
                if let error = error {
                    self?.error = error
                }
            })
        }
        
        if let information = profile.information?.toData() {
            dataManager.write(information, as: .information, completion: { [weak self] error in
                if let error = error {
                    self?.error = error
                }
            })
        }
        if let photo = profile.photo?.pngData() {
            dataManager.write(photo, as: .photo, completion: { [weak self] error in
                if let error = error {
                    self?.error = error
                }
            })
        }
    }
}
