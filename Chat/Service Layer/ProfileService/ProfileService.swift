import Foundation

protocol ProfileService {
    func loadProfile(_ completion: @escaping (Result<ProfileModel, Error>) -> Void)
    func saveProfile(_ profile: ProfileModel, _ completion: @escaping (Error?) -> Void)
}
