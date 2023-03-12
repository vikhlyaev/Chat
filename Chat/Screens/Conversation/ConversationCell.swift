import UIKit

final class ConversationCell: UITableViewCell {
    
    static let identifier = String(describing: ConversationCell.self)
    
    private lazy var messageView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.alpha = 0.6
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        contentView.addSubview(messageView)
        messageView.addSubview(bubbleImageView)
        messageView.addSubview(messageLabel)
        messageView.addSubview(timeLabel)
    }
    
    private func setBubbleImage(type: MessageType) {
        let bubbleImage: UIImage
        switch type {
        case .sent:
            guard let image = UIImage(named: "ChatBubbleSent") else { return }
            bubbleImage = image
        case .received:
            guard let image = UIImage(named: "ChatBubbleReceived") else { return }
            bubbleImage = image
        }
        
        bubbleImageView.image = bubbleImage.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
    }
    
    private func setBubbleColor(type: MessageType) {
        switch type {
        case .sent:
            bubbleImageView.tintColor = .customBubbleSent
        case .received:
            bubbleImageView.tintColor = .customBubbleReceived
        }
    }
    
    private func setTextColor(type: MessageType) {
        switch type {
        case .sent:
            messageLabel.textColor = .white
            timeLabel.textColor = .customLightGrey
        case .received:
            messageLabel.textColor = .black
            timeLabel.textColor = .customDarkGrey
        }
    }
    
    private func setBubbleConstraints(type: MessageType) {
        switch type {
        case .sent:
            messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        case .received:
            messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        }
    }
}

// MARK: - ConfigurableViewProtocol

extension ConversationCell: ConfigurableViewProtocol {
    func configure(with model: MessageCellModel) {
        messageLabel.text = model.text
        timeLabel.text = model.date.onlyHoursAndMinutes()
        setBubbleImage(type: model.type)
        setBubbleColor(type: model.type)
        setTextColor(type: model.type)
        setBubbleConstraints(type: model.type)
    }
}

// MARK: - Setting Constraints

extension ConversationCell {
    func setConstraints() {
        let messageViewWidth = messageView.widthAnchor.constraint(lessThanOrEqualToConstant: frame.width * 0.75)
        messageViewWidth.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            messageViewWidth,
            
            bubbleImageView.topAnchor.constraint(equalTo: messageView.topAnchor),
            bubbleImageView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor),
            bubbleImageView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor),
            bubbleImageView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor),
            
            timeLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -6),
            timeLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -12),
            
            messageLabel.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 6),
            messageLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -4),
            messageLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -6),
        ])
    }
}
