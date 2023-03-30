import UIKit
import Dispatch

protocol ConcurrencyServiceProtocol: AnyObject {
    func loadProfile(completion: @escaping (Result<ProfileViewModel, Error>) -> Void)
    func saveProfile(_ profile: ProfileViewModel, completion: @escaping (Error?) -> Void)
}

final class ConcurrencyService {
    private let queue = DispatchQueue(label: "ConcurrencyService.vikhlyaev", qos: .userInitiated, attributes: .concurrent)
    private let dataManager: DataManagerProtocol = DataManager()
}

// MARK: - ConcurrencyServiceProtocol

extension ConcurrencyService: ConcurrencyServiceProtocol {
    func loadProfile(completion: @escaping (Result<ProfileViewModel, Error>) -> Void) {
        var resultProfile = ProfileViewModel()
        
        let loadData = DispatchWorkItem { [weak self] in
            self?.dataManager.read(type: .plistData) { result in
                switch result {
                case .success(let plistData):
                    if let profile = try? PropertyListDecoder().decode(ProfileViewModel.self, from: plistData) {
                        resultProfile.name = profile.name
                        resultProfile.information = profile.information
                    } else {
                        DispatchQueue.main.async { completion(.failure(ConcurrencyServiceError.decodingError)) }
                    }
                case .failure(_):
                    DispatchQueue.main.async { completion(.failure(DataManagerError.dataReadError)) }
                }
            }
        }
        
        let loadPhoto = DispatchWorkItem { [weak self] in
            self?.dataManager.read(type: .photo) { result in
                switch result {
                case .success(let photoData):
                    if let photo = UIImage(data: photoData) {
                        resultProfile.photo = photo
                    }
                case .failure(_):
                    resultProfile.photo = UIImage(named: "PlaceholderAvatar")
                }
            }
        }
    
        let group = DispatchGroup()
        queue.async(group: group, execute: loadData)
        queue.async(group: group, execute: loadPhoto)
        group.notify(queue: .main) {
            completion(.success(resultProfile))
            print("Loaded profile")
        }
    }
    
    func saveProfile(_ profile: ProfileViewModel, completion: @escaping (Error?) -> Void) {
        let saveData = DispatchWorkItem { [weak self] in
            guard let plistData = try? PropertyListEncoder().encode(profile) else { return }
            self?.dataManager.write(plistData, as: .plistData, completion: { error in
                DispatchQueue.main.async { completion(error) }
            })
        }
        
        let savePhoto = DispatchWorkItem { [weak self] in
            guard let photo = profile.photo, let photoData = photo.pngData() else { return }
            sleep(3)
            self?.dataManager.write(photoData, as: .photo, completion: { error in
                DispatchQueue.main.async { completion(error) }
            })
        }
        
        let group = DispatchGroup()
        queue.async(group: group, execute: saveData)
        queue.async(group: group, execute: savePhoto)
        group.notify(queue: .main) {
            completion(nil)
            print("Saved profile")
        }
    }
}

enum ConcurrencyServiceError: Error {
    case decodingError
    case encodingError
}
