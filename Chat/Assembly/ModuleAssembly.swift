import UIKit

final class ModuleAssembly {
    
    private let serviceAssembly: ServiceAssembly

    init(serviceAssembly: ServiceAssembly) {
        self.serviceAssembly = serviceAssembly
    }
    
    func makeChannelsListModule(moduleOutput: ChannelsListModuleOutput) -> UIViewController {
        let presenter = ChannelsListPresenter(
            dataService: serviceAssembly.makeDataService(),
            moduleOutput: moduleOutput
        )
        let vc = ChannelsListViewController(output: presenter)
        presenter.viewInput = vc
        return vc
    }
    
    func makeChannelModule(with channel: ChannelModel, and moduleOutput: ChannelModuleOutput) -> UIViewController {
        let presenter = ChannelPresenter(
            dataService: serviceAssembly.makeDataService(),
            profileService: serviceAssembly.makeProfileService(),
            photoLoaderService: serviceAssembly.makePhotoLoaderService(),
            alertCreatorService: serviceAssembly.makeAlertCreaterService(),
            moduleOutput: moduleOutput,
            channel: channel)
        let vc = ChannelViewController(output: presenter)
        presenter.viewInput = vc
        return vc
    }
    
    func makeSettingsModule() -> UIViewController {
        let presenter = SettingsPresenter(
            themesService: serviceAssembly.makeThemesService()
        )
        let vc = SettingsViewController(output: presenter)
        presenter.viewInput = vc
        return vc
    }
    
    func makeProfileModule(moduleOutput: ProfileModuleOutput) -> UIViewController {
        let presenter = ProfilePresenter(
            profileService: serviceAssembly.makeProfileService(),
            photoLoaderService: serviceAssembly.makePhotoLoaderService(),
            photoAddingService: serviceAssembly.makePhotoAddingService(),
            alertCreatorService: serviceAssembly.makeAlertCreaterService(),
            moduleOutput: moduleOutput
        )
        let vc = ProfileViewController(output: presenter)
        presenter.viewInput = vc
        return vc
    }
    
    func makeProfileEditModule(
        with profileModel: ProfileModel,
        moduleOutput: ProfileEditModuleOutput,
        transitioningDelegate: UIViewControllerTransitioningDelegate,
        delegate: ProfileEditDelegate
    ) -> UIViewController {
        let presenter = ProfileEditPresenter(
            profileModel: profileModel,
            profileService: serviceAssembly.makeProfileService(),
            photoLoaderService: serviceAssembly.makePhotoLoaderService(),
            photoAddingService: serviceAssembly.makePhotoAddingService(),
            alertCreatorService: serviceAssembly.makeAlertCreaterService(),
            moduleOutput: moduleOutput,
            delegate: delegate
        )
        let vc = ProfileEditViewController(output: presenter)
        presenter.viewInput = vc
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.transitioningDelegate = transitioningDelegate
        return navigationController
    }
    
    func makePhotoSelectionModule(with delegate: PhotoSelectionDelegate) -> UIViewController {
        let presenter = PhotoSelectionPresenter(
            photoLoaderService: serviceAssembly.makePhotoLoaderService(),
            alertCreatorService: serviceAssembly.makeAlertCreaterService(),
            delegate: delegate
        )
        let vc = PhotoSelectionViewController(output: presenter)
        let navigationController = UINavigationController(rootViewController: vc)
        presenter.viewInput = vc
        return navigationController
    }

}
