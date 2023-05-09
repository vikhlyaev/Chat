import Foundation

protocol ProfileEditViewOutput {
    var profileModel: ProfileModel? { get }
    func viewIsReady()
    func didUpdatePhoto()
    func didSaveProfile(_ profile: ProfileModel)
}
