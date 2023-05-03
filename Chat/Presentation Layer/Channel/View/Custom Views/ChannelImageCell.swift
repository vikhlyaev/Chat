import UIKit

final class ChannelImageCell: UITableViewCell {
    
    private lazy var wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.alpha = 0.6
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.alpha = 0.6
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    weak var delegate: ChannelPhotoCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        contentView.addSubview(photoImageView)
        photoImageView.addSubview(activityIndicator)
        contentView.addSubview(nameLabel)
        contentView.addSubview(timeLabel)
    }
    
    private func setupSentCell(with model: MessageModel) {
        timeLabel.textColor = .appBubbleTextReceived
        photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = false
    }
    
    private func setupReceivedCell(with model: MessageModel) {
        timeLabel.textColor = .appBubbleTextReceived
        nameLabel.text = model.userName
        photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = false
        photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
    }
    
    func resetCell() {
        photoImageView.image = nil
        nameLabel.text = nil
        timeLabel.text = nil
    }
    
    func configure(cellType: CellType, with model: MessageModel) {
        switch cellType {
        case .imageSent:
            setupSentCell(with: model)
        case .imageReceived:
            setupReceivedCell(with: model)
        case .textSent, .textReceived: break
        }
        
        timeLabel.text = model.date.onlyHoursAndMinutes()
        photoImageView.image = UIImage(named: "PlaceholderPhoto")
        activityIndicator.startAnimating()
        delegate?.didRecieveImage(by: model.text) { [weak self] image in
            self?.activityIndicator.stopAnimating()
            self?.photoImageView.image = image
        }
    }
}

// MARK: - Setting Constraints

extension ChannelImageCell {
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            
            photoImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            photoImageView.widthAnchor.constraint(equalToConstant: 150),
            photoImageView.heightAnchor.constraint(equalToConstant: 150),
            
            activityIndicator.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor),
            
            timeLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 4),
            timeLabel.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
}
