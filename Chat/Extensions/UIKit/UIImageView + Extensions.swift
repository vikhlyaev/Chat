import UIKit

extension UIImageView {
    func load(url: String?) {
        guard let urlString = url, let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async { self.image = image }
            } else {
                DispatchQueue.main.async { self.image = UIImage(named: "PlaceholderChannel") }
            }
            
        }
    }
}
