import UIKit

final class PhotoSelectionCell: UICollectionViewCell {
    
    private lazy var wrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    weak var delegate: PhotoSelectionCellDelegate?
    
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
        wrapperView.addSubview(activityIndicator)
    }
    
    func configure(with photoModel: PhotoModel) {
        activityIndicator.startAnimating()
        photoImageView.image = UIImage(named: "PlaceholderPhoto")

        delegate?.didRecievePhoto(for: photoModel, { [weak self] photo in
            if let photo = photo {
                self?.photoImageView.image = photo
                self?.activityIndicator.stopAnimating()
            }
        })
    }
    
    func resetCell() {
        photoImageView.image = nil
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
            photoImageView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
