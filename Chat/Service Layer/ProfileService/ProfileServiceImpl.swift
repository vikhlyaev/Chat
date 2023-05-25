import UIKit

final class ProfileServiceImpl {
    
    private let coreDataService: CoreDataService
    private let fileManagerService: FileManagerService
    
    init(coreDataService: CoreDataService, fileManagerService: FileManagerService) {
        self.coreDataService = coreDataService
        self.fileManagerService = fileManagerService
    }
    
    private func loadPhoto(_ completion: @escaping (Result<UIImage, Error>) -> Void) {
        fileManagerService.read(by: "photoData") { result in
            switch result {
            case .success(let photoData):
                if let image = UIImage(data: photoData) {
                    completion(.success(image))
                } else {
                    completion(.failure(ProfileServiceError.badPhoto))
                }
            case .failure:
                completion(.failure(ProfileServiceError.badData))
            }
        }
    }
    
    private func savePhoto(_ profile: ProfileModel, _ completion: @escaping (Error?) -> Void) {
        guard
            let photo = profile.photo,
            let photoData = photo.pngData()
        else { return }
        fileManagerService.write(photoData, with: "photoData") { error in
            guard let error else {
                completion(nil)
                return
            }
            completion(error)
        }
    }
}

// MARK: - ProfileService

extension ProfileServiceImpl: ProfileService {
    func loadProfile(_ completion: @escaping (Result<ProfileModel, Error>) -> Void) {
        do {
            guard let profileManagedObject = try coreDataService.fetchProfile().first else {
                let profileModel = ProfileModel(
                    name: "No name",
                    information: "No bio specified",
                    photo: UIImage(named: "PlaceholderAvatar")
                )
                completion(.success(profileModel))
                return
            }
            var profileModel = ProfileModel(id: profileManagedObject.id,
                                            name: profileManagedObject.name,
                                            information: profileManagedObject.info)
            loadPhoto { result in
                switch result {
                case .success(let photo):
                    profileModel.photo = photo
                    completion(.success(profileModel))
                case .failure:
                    completion(.success(profileModel))
                }
            }
        } catch {
            completion(.failure(ProfileServiceError.badProfile))
        }
    }
    
    func saveProfile(_ profile: ProfileModel, _ completion: @escaping (Error?) -> Void) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.coreDataService.update { context in
                let fetchRequest = ProfileManagedObject.fetchRequest()
                if let profileManagedObject = try context.fetch(fetchRequest).first {
                    profileManagedObject.name = profile.name
                    profileManagedObject.info = profile.information
                } else {
                    let profileManagedObject = ProfileManagedObject(context: context)
                    profileManagedObject.id = "\(UUID())"
                    profileManagedObject.name = profile.name
                    profileManagedObject.info = profile.information
                }
            }
            self?.savePhoto(profile) { error in
                guard let error else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
        
    }
}
