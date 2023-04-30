import UIKit

final class SettingsAssembly {

    private let serviceAssembly: ServiceAssembly

    init(serviceAssembly: ServiceAssembly) {
        self.serviceAssembly = serviceAssembly
    }

    func makeSettingsModule() -> UIViewController {
        let presenter = SettingsPresenter(
            themesService: serviceAssembly.makeThemesService()
        )
        let vc = SettingsViewController(output: presenter)
        presenter.viewInput = vc
        return vc
    }
    
}
