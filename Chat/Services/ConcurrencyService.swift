import UIKit
import Dispatch
import Combine

protocol ConcurrencyServiceProtocol: AnyObject {
    func loadProfilePublisher() -> AnyPublisher<ProfileViewModel,Error>
    func saveProfile(_ profile: ProfileViewModel, completion: @escaping (Error?) -> Void)
}

final class ConcurrencyService {
    private let queue = DispatchQueue(label: "ConcurrencyService.vikhlyaev", qos: .userInitiated, attributes: .concurrent)
    private let dataManager: DataManagerProtocol = DataManager()
}

// MARK: - ConcurrencyServiceProtocol

extension ConcurrencyService: ConcurrencyServiceProtocol {
    
    func loadProfilePublisher() -> AnyPublisher<ProfileViewModel, Error> {
        Deferred {
            Future { promise in
                var resultProfile = ProfileViewModel()
                
                let loadProfileData = self.dataManager.readPublisher(type: .plistData)
                    .decode(type: ProfileViewModel.self, decoder: PropertyListDecoder())
                    
                let loadProfilePhoto = self.dataManager.readPublisher(type: .photo)
                    .map({ UIImage(data: $0) })
                   
                _ = Publishers.CombineLatest(loadProfileData, loadProfilePhoto)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                print("profile loaded")
                            case .failure(let error):
                                promise(.failure(error))
                            }
                        }, receiveValue: { profile, photo in
                            resultProfile = profile
                            resultProfile.photo = photo
                        })
                
                promise(.success(resultProfile))
            }
        }.eraseToAnyPublisher()
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
