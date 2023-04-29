import Foundation

protocol ProfileViewOutput {
    var profileModel: ProfileModel? { get }
    func viewIsReady()
    func saveProfile(_ profile: ProfileModel)
    func takePhoto()
    func chooseFromGallery()
    func loadFromNetwork()
}
