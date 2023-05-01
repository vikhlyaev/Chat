import Foundation

protocol ProfileViewOutput {
    var profileModel: ProfileModel? { get }
    func viewIsReady()
    func didSaveProfile(_ profile: ProfileModel)
    func didTakePhoto()
    func didChooseFromGallery()
    func didLoadFromNetwork()
}
