import UIKit
import Dispatch

protocol ConcurrencyServiceProtocol {
    func loadProfile(completion: @escaping (Result<ProfileViewModel, DataManagerError>) -> Void)
    func saveProfile(profile: ProfileViewModel, completion: @escaping (DataManagerError?) -> Void)
    func saveData(_ data: Data, as type: DataType, completion: @escaping (DataManagerError?) -> Void)
}

final class GCDService {
    private let queue = DispatchQueue(label: "GCDService.vikhlyaev", qos: .userInitiated, attributes: .concurrent)
    private lazy var dataManager: DataManagerProtocol = DataManager()
}

// MARK: - ConcurrencyServiceProtocol

extension GCDService: ConcurrencyServiceProtocol {
    func loadProfile(completion: @escaping (Result<ProfileViewModel, DataManagerError>) -> Void) {
        var name: String = "No name"
        var information: String = "No bio specified"
        var photo: UIImage?
        
        let loadName = DispatchWorkItem { [weak self] in
            self?.dataManager.read(.name, completion: { result in
                switch result {
                case .success(let data):
                    name = String(data: data, encoding: .utf8) ?? ""
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        
        let loadInformation = DispatchWorkItem { [weak self] in
            self?.dataManager.read(.information, completion: { result in
                switch result {
                case .success(let data):
                    information = String(data: data, encoding: .utf8) ?? ""
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        
        let loadPhoto = DispatchWorkItem { [weak self] in
            self?.dataManager.read(.photo, completion: { result in
                switch result {
                case .success(let data):
                    photo = UIImage(data: data)
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        
        let group = DispatchGroup()
        queue.async(group: group, execute: loadName)
        queue.async(group: group, execute: loadInformation)
        queue.async(group: group, execute: loadPhoto)
        group.wait()
        
        DispatchQueue.main.async {
            completion(.success(ProfileViewModel(name: name,
                                                 information: information,
                                                 photo: photo)))
        }
    }
    
    func saveProfile(profile: ProfileViewModel, completion: @escaping (DataManagerError?) -> Void){
        let saveName = DispatchWorkItem { [weak self] in
            if let name = profile.name?.toData() {
                self?.dataManager.write(name, as: .name, completion: { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(error)
                        }
                        completion(nil)
                    }
                })
            }
        }
        
        let saveInformation = DispatchWorkItem { [weak self] in
            if let information = profile.information?.toData() {
                self?.dataManager.write(information, as: .information, completion: { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(error)
                        }
                        completion(nil)
                    }
                })
            }
        }
    
        let saveImage = DispatchWorkItem { [weak self] in
            if let photo = profile.photo?.pngData() {
                self?.dataManager.write(photo, as: .photo, completion: { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(error)
                        }
                        completion(nil)
                    }
                })
            }
        }
        
        queue.async(execute: saveName)
        queue.async(execute: saveInformation)
        queue.async(execute: saveImage)
    }
    func saveData(_ data: Data, as type: DataType, completion: @escaping (DataManagerError?) -> Void) {
        queue.async { [weak self] in
            self?.dataManager.write(data, as: type, completion: { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(error)
                    }
                    completion(nil)
                }
            })
        }
    }
}
