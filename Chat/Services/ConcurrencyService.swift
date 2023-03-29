import UIKit
import Dispatch

protocol ConcurrencyServiceProtocol {
    func loadProfile(completion: @escaping (Result<ProfileViewModel, DataManagerError>) -> Void)
    func saveProfile(profile: ProfileViewModel, completion: @escaping (DataManagerError?) -> Void)
}

final class ConcurrencyService {
    private let queue = DispatchQueue(label: "ConcurrencyService.vikhlyaev", qos: .userInitiated, attributes: .concurrent)
    private lazy var dataManager: DataManagerProtocol = DataManager()
    
    private func load(type: DataType, completion: @escaping (Result<Data, DataManagerError>) -> Void) {
        queue.async { [weak self] in
            self?.dataManager.read(type) { result in
                completion(result)
            }
        }
    }
    
    private func save(_ data: Data, as type: DataType, completion: @escaping (DataManagerError?) -> Void) {
        queue.async { [weak self] in
            self?.dataManager.write(data, as: type, completion: { error in
                completion(error)
            })
        }
    }
}

// MARK: - ConcurrencyServiceProtocol

extension ConcurrencyService: ConcurrencyServiceProtocol {
    func loadProfile(completion: @escaping (Result<ProfileViewModel, DataManagerError>) -> Void) {
        var name: String = "No name"
        var information: String = "No bio specified"
        var photo: UIImage?
        
        let loadNameItem = DispatchWorkItem { [weak self] in
            self?.load(type: .name) { result in
                switch result {
                case .success(let nameData):
                    if let nameString = String(data: nameData, encoding: .utf8) {
                        name = nameString
                    } else {
                        DispatchQueue.main.async { completion(.failure(.badData)) }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
        }
        
        let loadInfoItem = DispatchWorkItem { [weak self] in
            self?.load(type: .information) { result in
                switch result {
                case .success(let informationData):
                    if let informationString = String(data: informationData, encoding: .utf8) {
                        information = informationString
                    } else {
                        DispatchQueue.main.async { completion(.failure(.badData)) }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {  completion(.failure(error)) }
                }
            }
        }
        
        let loadPhotoItem = DispatchWorkItem { [weak self] in
            self?.load(type: .photo) { result in
                switch result {
                case .success(let photoData):
                    if let photoImage = UIImage(data: photoData) {
                        photo = photoImage
                    } else {
                        DispatchQueue.main.async { completion(.failure(.badData)) }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
        }
        
        let group = DispatchGroup()
        queue.async(group: group, execute: loadNameItem)
        queue.async(group: group, execute: loadInfoItem)
        queue.async(group: group, execute: loadPhotoItem)
        
        group.notify(queue: .main) {
            completion(.success(ProfileViewModel(name: name,
                                                 information: information,
                                                 photo: photo)))
        }
    }
    
    func saveProfile(profile: ProfileViewModel, completion: @escaping (DataManagerError?) -> Void) {
        let saveName = DispatchWorkItem { [weak self] in
            if let nameData = profile.name?.toData() {
                self?.save(nameData, as: .name) { error in
                    DispatchQueue.main.async { completion(error) }
                }
            }
        }
        
        let saveInfo = DispatchWorkItem { [weak self] in
            if let infoData = profile.information?.toData() {
                self?.save(infoData, as: .information) { error in
                    DispatchQueue.main.async { completion(error) }
                }
            }
        }
        
        let savePhoto = DispatchWorkItem { [weak self] in
            if let photoData = profile.photo?.pngData() {
                self?.save(photoData, as: .photo) { error in
                    DispatchQueue.main.async { completion(error) }
                }
            }
        }
        
        let group = DispatchGroup()
        queue.async(group: group, execute: saveName)
        queue.async(group: group, execute: saveInfo)
        queue.async(group: group, execute: savePhoto)
        
        group.notify(queue: .main) {
            completion(nil)
        }
    }
}
