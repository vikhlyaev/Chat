import UIKit

final class ChannelAssembly {

    private let serviceAssembly: ServiceAssembly

    init(serviceAssembly: ServiceAssembly) {
        self.serviceAssembly = serviceAssembly
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
    
}
