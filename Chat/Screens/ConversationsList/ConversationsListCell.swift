import UIKit

final class ConversationsListCell: UITableViewCell {
    
    static let identifier = String(describing: ConversationsListCell.self)
    
    private lazy var photoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 22.5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var wrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.alpha = 0.6
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateAndTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.alpha = 0.3
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var disclosureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "IconChevronRight")
        imageView.tintColor = .label
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        contentView.addSubview(photoView)
        photoView.addSubview(photoImageView)
        contentView.addSubview(wrapperView)
        wrapperView.addSubview(nameLabel)
        wrapperView.addSubview(dateAndTimeLabel)
        wrapperView.addSubview(lastMessageLabel)
        wrapperView.addSubview(disclosureImageView)
    }
    
    func resetCell() {
        nameLabel.text = nil
        photoImageView.image = nil
        dateAndTimeLabel.text = nil
        lastMessageLabel.text = nil
        lastMessageLabel.font = .systemFont(ofSize: 15, weight: .regular)
        lastMessageLabel.alpha = 0.6
    }
}

// MARK: - ConfigurableViewProtocol

extension ConversationsListCell: ConfigurableViewProtocol {
    func configure(with model: ConversationsListCellModel) {
        nameLabel.text = model.name
        photoImageView.image = model.photo
        dateAndTimeLabel.text = model.date?.toString()

        if let message = model.message {
            lastMessageLabel.text = message
        } else {
            lastMessageLabel.text = "No messages yet"
            lastMessageLabel.font = .italicSystemFont(ofSize: 15)
        }
        
        if model.hasUnreadMessages {
            lastMessageLabel.font = .boldSystemFont(ofSize: 15)
            lastMessageLabel.alpha = 1
        }
    }
}

// MARK: - Setting Constraints

extension ConversationsListCell {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            photoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            photoView.heightAnchor.constraint(equalToConstant: 45),
            photoView.widthAnchor.constraint(equalToConstant: 45),
            
            photoImageView.topAnchor.constraint(equalTo: photoView.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: photoView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: photoView.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: photoView.bottomAnchor),
            
            wrapperView.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 12),
            wrapperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            wrapperView.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            
            dateAndTimeLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 4),
            dateAndTimeLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            
            disclosureImageView.leadingAnchor.constraint(equalTo: dateAndTimeLabel.trailingAnchor, constant: 14),
            disclosureImageView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
            disclosureImageView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            
            lastMessageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            lastMessageLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            lastMessageLabel.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
            lastMessageLabel.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor)
        ])
    }
}
