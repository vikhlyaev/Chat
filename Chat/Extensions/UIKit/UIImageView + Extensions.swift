import UIKit
import Combine

extension UIImageView {
    func loadImage(url: String?) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let urlString = url,
                  let url = URL(string: urlString),
                  let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data)
            else {
                DispatchQueue.main.async { self.image = UIImage(named: "PlaceholderChannel") }
                return
            }
            DispatchQueue.main.async { self.image = image }
        }
    }
}
