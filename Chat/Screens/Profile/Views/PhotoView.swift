import UIKit

final class PhotoView: UIView {
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var initialsLabel: UILabel = {
        let label = UILabel()
        label.font = .rounded(ofSize: 64, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2.0
    }
    
    private func setupView() {
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(photoImageView)
        photoImageView.addSubview(initialsLabel)
    }
    
    func addInitials(_ initials: String) {
        initialsLabel.text = initials
    }
    
    func removeInitials() {
        initialsLabel.removeFromSuperview()
        initialsLabel.removeConstraints([
            initialsLabel.centerXAnchor.constraint(equalTo: self.photoImageView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: self.photoImageView.centerYAnchor)
        ])
    }
    
    func updatePhoto(_ image: UIImage) {
        photoImageView.image = image
    }
}

// MARK: - Setting Constraints

extension PhotoView {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            initialsLabel.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor)
        ])
    }
}


