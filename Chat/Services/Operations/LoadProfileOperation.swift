import UIKit

final class LoadProfileOperation: Operation {
    private lazy var dataManager: DataManagerProtocol = DataManager()
    private var profileName: String = "No name"
    private var information: String = "No bio specified"
    private var photo: UIImage?
    var profile: ProfileViewModel?
    var error: DataManagerError?
    
    override func main() {
        dataManager.read(.name, completion: { [weak self] result in
            switch result {
            case .success(let data):
                self?.profileName = String(data: data, encoding: .utf8) ?? ""
            case .failure(let error):
                self?.error = error
            }
        })
        dataManager.read(.information, completion: { [weak self] result in
            switch result {
            case .success(let data):
                self?.information = String(data: data, encoding: .utf8) ?? ""
            case .failure(let error):
                self?.error = error
            }
        })
        dataManager.read(.photo, completion: { [weak self] result in
            switch result {
            case .success(let data):
                self?.photo = UIImage(data: data)
            case .failure(let error):
                self?.error = error
            }
        })
        
        profile = ProfileViewModel(name: profileName,
                                   information: information,
                                   photo: photo)
    }
}
