import UIKit

extension UIImageView {
    func load(url: String) {
        guard let url = URL(string: url) else { return }
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }
            guard let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.image = image }
        }
    }
}
