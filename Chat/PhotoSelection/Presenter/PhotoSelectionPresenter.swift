import UIKit

final class PhotoSelectionPresenter {
    
    weak var viewInput: PhotoSelectionViewInput?
    
    var photos: [UIImage] = [
        UIImage(named: "0") ?? UIImage(),
        UIImage(named: "1") ?? UIImage(),
        UIImage(named: "2") ?? UIImage(),
        UIImage(named: "3") ?? UIImage(),
        UIImage(named: "4") ?? UIImage()
    ]
}

// MARK: - PhotoSelectionViewOutput

extension PhotoSelectionPresenter: PhotoSelectionViewOutput {
    func viewIsReady() {
        
    }
}
