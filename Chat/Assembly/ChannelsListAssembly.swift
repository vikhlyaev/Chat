import UIKit

final class ChannelsListAssembly {

    private let serviceAssembly: ServiceAssembly

    init(serviceAssembly: ServiceAssembly) {
        self.serviceAssembly = serviceAssembly
    }

    func makeChannelsListModule() -> UIViewController {
        let presenter = ChannelsListPresenter(
            dataService: serviceAssembly.makeDataService()
        )
        let vc = ChannelsListViewController(output: presenter)
        presenter.viewInput = vc
        return vc
    }
    
}
