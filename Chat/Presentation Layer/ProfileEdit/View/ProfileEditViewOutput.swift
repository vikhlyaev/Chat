import Foundation

protocol ProfileEditViewOutput {
    var profileModel: ProfileModel? { get }
    func viewIsReady()
    func didTakePhoto()
    func didChooseFromGallery()
    func didLoadFromNetwork()
    func didSaveProfile(_ profile: ProfileModel)
}
