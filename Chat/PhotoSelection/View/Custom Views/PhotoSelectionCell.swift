import UIKit

final class PhotoSelectionCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: PhotoSelectionCell.self)
    
    private lazy var wrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(wrapperView)
        wrapperView.addSubview(photoImageView)
    }
    
    func configure(with image: UIImage) {
        photoImageView.image = image
    }
}

// MARK: - Setting Constraints

extension PhotoSelectionCell {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: contentView.topAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            photoImageView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor)
        ])
    }
}
