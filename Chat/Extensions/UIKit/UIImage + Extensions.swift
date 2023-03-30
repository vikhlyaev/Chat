import UIKit

extension UIImage {
    static func makeRandomAvatar(with name: String) -> UIImage {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        let initials = name.split(separator: " ").compactMap { String($0).first }.map { String($0) }.prefix(2).joined()
        let placeholder = UIImage(named: "Placeholder") ?? UIImage()
        let gradient = CAGradientLayer()
        let defaultColorsGradient = [UIColor(red: 0.95, green: 0.62, blue: 0.71, alpha: 1.00).cgColor,                                                         UIColor(red: 0.93, green: 0.48, blue: 0.58, alpha: 1.00).cgColor]
        let colors = [[UIColor(red: 0.21, green: 0.82, blue: 0.86, alpha: 1.00).cgColor,
                       UIColor(red: 0.36, green: 0.53, blue: 0.90, alpha: 1.00).cgColor],
                      [UIColor(red: 0.27, green: 0.63, blue: 0.55, alpha: 1.00).cgColor,
                       UIColor(red: 0.04, green: 0.21, blue: 0.22, alpha: 1.00).cgColor],
                      [UIColor(red: 0.90, green: 0.22, blue: 0.21, alpha: 1.00).cgColor,
                       UIColor(red: 0.89, green: 0.36, blue: 0.36, alpha: 1.00).cgColor],
                      [UIColor(red: 0.39, green: 0.25, blue: 0.65, alpha: 1.00).cgColor,
                       UIColor(red: 0.16, green: 0.03, blue: 0.27, alpha: 1.00).cgColor],
                      [UIColor(red: 0.00, green: 0.78, blue: 1.00, alpha: 1.00).cgColor,
                       UIColor(red: 0.00, green: 0.45, blue: 1.00, alpha: 1.00).cgColor],
                      [UIColor(red: 0.95, green: 0.44, blue: 0.61, alpha: 1.00).cgColor,
                       UIColor(red: 1.00, green: 0.58, blue: 0.45, alpha: 1.00).cgColor],
                      [UIColor(red: 0.25, green: 0.30, blue: 0.04, alpha: 1.00).cgColor,
                       UIColor(red: 0.45, green: 0.48, blue: 0.09, alpha: 1.00).cgColor],
                      [UIColor(red: 0.45, green: 0.78, blue: 0.66, alpha: 1.00).cgColor,
                       UIColor(red: 0.22, green: 0.23, blue: 0.27, alpha: 1.00).cgColor]
        ]
        
        gradient.frame = view.bounds
        gradient.colors = colors.randomElement() ?? defaultColorsGradient
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        let label = UILabel(frame: view.bounds)
        label.textColor = .white
        label.text = initials
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.font = .rounded(ofSize: 66, weight: .semibold)
        
        view.layer.addSublayer(gradient)
        view.addSubview(label)
        
        UIGraphicsBeginImageContext(view.frame.size)
        guard let cgContext = UIGraphicsGetCurrentContext() else { return placeholder }
        view.layer.render(in: cgContext)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? placeholder
    }
    
    func toPngString() -> String {
        guard let data = pngData() else { return "" }
        return data.base64EncodedString(options: .endLineWithLineFeed)
    }
}
