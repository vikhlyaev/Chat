import UIKit

final class PhotoSelectionAssembly {

    private let serviceAssembly: ServiceAssembly

    init(serviceAssembly: ServiceAssembly) {
        self.serviceAssembly = serviceAssembly
    }

    func makePhotoSelectionModule() -> UIViewController {
        let presenter = PhotoSelectionPresenter(
            photoLoaderService: serviceAssembly.makePhotoLoaderService()
        )
        let vc = PhotoSelectionViewController(output: presenter)
        presenter.viewInput = vc
        return vc
    }
    
}
