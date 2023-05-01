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
    
    func makeChannelModule(with channel: ChannelModel) -> UIViewController {
        let presenter = ChannelPresenter(
            dataService: serviceAssembly.makeDataService(),
            profileService: serviceAssembly.makeProfileService(),
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
            moduleOutput: moduleOutput
        )
        let vc = ProfileViewController(output: presenter)
        presenter.viewInput = vc
        return vc
    }
    
    func makePhotoSelectionModule(with delegate: PhotoSelectionDelegate) -> UIViewController {
        let presenter = PhotoSelectionPresenter(
            photoLoaderService: serviceAssembly.makePhotoLoaderService()
        )
        let vc = PhotoSelectionViewController(output: presenter, delegate: delegate)
        let navigationController = UINavigationController(rootViewController: vc)
        presenter.viewInput = vc
        return navigationController
    }

}
