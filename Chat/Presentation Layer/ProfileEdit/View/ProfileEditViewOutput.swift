import Foundation

protocol ProfileEditViewOutput {
    var profileModel: ProfileModel? { get }
    func viewIsReady()
    func didOpenPhotoAddingAlertSheet()
    func didSaveProfile(_ profile: ProfileModel)
}
