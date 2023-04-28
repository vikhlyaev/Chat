import UIKit

final class ProfileServiceImpl {
    
    private let coreDataService: CoreDataService
    private let fileManagerService: FileManagerService
    private let logService: LogService
    
    init(coreDataService: CoreDataService, fileManagerService: FileManagerService, logService: LogService) {
        self.coreDataService = coreDataService
        self.fileManagerService = fileManagerService
        self.logService = logService
    }
    
    private func loadPhoto(_ completion: @escaping (Result<UIImage, Error>) -> Void) {
        fileManagerService.read(by: "photoData") { [weak self] result in
            switch result {
            case .success(let photoData):
                if let image = UIImage(data: photoData) {
                    completion(.success(image))
                    self?.logService.success("Photo successfully load")
                } else {
                    completion(.failure(ProfileServiceError.badPhoto))
                    self?.logService.error("Photo not load")
                }
            case .failure(let error):
                completion(.failure(ProfileServiceError.badData))
                self?.logService.error("Photo not load. Error: \(error)")
            }
        }
    }
    
    private func savePhoto(_ profile: ProfileModel, _ completion: @escaping (Error?) -> Void) {
        guard
            let photo = profile.photo,
            let photoData = photo.pngData()
        else {
            logService.error("No photo found")
            return
        }
        fileManagerService.write(photoData, with: "photoData") { [weak self] error in
            guard let error else {
                self?.logService.success("Photo successfully update")
                completion(nil)
                return
            }
            completion(error)
            self?.logService.error("Photo not update")
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
            var profileModel = ProfileModel(name: profileManagedObject.name,
                                            information: profileManagedObject.info)
            loadPhoto { [weak self] result in
                switch result {
                case .success(let photo):
                    profileModel.photo = photo
                    completion(.success(profileModel))
                    self?.logService.success("Profile with photo successfully load")
                case .failure(let error):
                    completion(.success(profileModel))
                    self?.logService.success("Profile without photo load. Error: \(error)")
                }
            }
        } catch {
            completion(.failure(ProfileServiceError.badProfile))
            logService.success("Profile not load")
        }
    }
    
    func saveProfile(_ profile: ProfileModel, _ completion: @escaping (Error?) -> Void) {
        coreDataService.update { context in
            let fetchRequest = ProfileManagedObject.fetchRequest()
            if let profileManagedObject = try context.fetch(fetchRequest).first {
                profileManagedObject.name = profile.name
                profileManagedObject.info = profile.information
                logService.success("Profile successfully update")
            } else {
                let profileManagedObject = ProfileManagedObject(context: context)
                profileManagedObject.name = profile.name
                profileManagedObject.info = profile.information
                logService.success("Profile successfully created")
            }
        }
        savePhoto(profile) { error in
            guard error != nil else {
                completion(nil)
                return
            }
            completion(error)
        }
    }
}

enum ProfileServiceError: Error {
    case badPhoto
    case badData
    case badProfile
    case nonexistentProfile
}
