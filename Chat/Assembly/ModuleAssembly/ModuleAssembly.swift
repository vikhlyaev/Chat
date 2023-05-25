import UIKit

protocol ModuleAssembly {
    func makeChannelsListModule(moduleOutput: ChannelsListModuleOutput) -> UIViewController
    func makeChannelModule(with channel: ChannelModel, and moduleOutput: ChannelModuleOutput) -> UIViewController
    func makeSettingsModule() -> UIViewController
    func makeProfileModule(moduleOutput: ProfileModuleOutput) -> UIViewController
    func makePhotoSelectionModule(with delegate: PhotoSelectionDelegate) -> UIViewController
    func makeProfileEditModule(
        with profileModel: ProfileModel,
        moduleOutput: ProfileEditModuleOutput,
        transitioningDelegate: UIViewControllerTransitioningDelegate,
        delegate: ProfileEditDelegate
    ) -> UIViewController
}
