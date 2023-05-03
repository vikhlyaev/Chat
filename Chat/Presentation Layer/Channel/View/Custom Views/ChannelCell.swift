import UIKit

final class ChannelCell: UITableViewCell {
    
    private lazy var bubbleView: BubbleView = {
        let view = BubbleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byClipping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        contentView.addSubview(nameLabel)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timeLabel)
    }
    
    private func setupSentCell(with model: MessageModel) {
        bubbleView.backgroundColor = .appBubbleSent
        bubbleView.arrowDirection = .right
        messageLabel.textColor = .appBubbleTextSent
        timeLabel.textColor = .appBubbleTextSent
        bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = false
    }
    
    private func setupReceivedCell(with model: MessageModel) {
        bubbleView.backgroundColor = .appBubbleReceived
        bubbleView.arrowDirection = .left
        messageLabel.textColor = .appBubbleTextReceived
        timeLabel.textColor = .appBubbleTextReceived
        nameLabel.text = model.userName
        bubbleView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = false
        bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
    }
    
    func configure(cellType: CellType, with model: MessageModel) {
        switch cellType {
        case .textSent: setupSentCell(with: model)
        case .textReceived: setupReceivedCell(with: model)
        case .imageSent, .imageReceived: break
        }
        messageLabel.text = model.text
        timeLabel.text = model.date.onlyHoursAndMinutes()
    }

    func resetCell() {
        nameLabel.text = nil
        messageLabel.text = nil
        timeLabel.text = nil
    }
}

// MARK: - Setting Constraints

extension ChannelCell {
    private func setConstraints() {
        let bubbleViewWidth = bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: frame.width * 0.75)
        bubbleViewWidth.priority = UILayoutPriority(999)
        messageLabel.setContentCompressionResistancePriority(UILayoutPriority(999), for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleViewWidth,
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 7),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            messageLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -4),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -7),
            
            timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -7),
            timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14)
        ])
    }
}
