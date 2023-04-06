import UIKit

extension UIImageView {
    func load(url: String?) {
        guard let urlString = url, let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.image = image }
        }
    }
}
