import UIKit

final class ThemesButton: UIButton {
    
    // MARK: - UI

    private lazy var interfaceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.isExclusiveTouch = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemGray
        imageView.image = uncheckedImage
        imageView.contentMode = .center
        imageView.isUserInteractionEnabled = false
        imageView.isExclusiveTouch = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var checkedImage = UIImage(systemName: "checkmark.circle.fill")
    private lazy var uncheckedImage = UIImage(systemName: "circle")
    
    // MARK: - States
    
    override var isHighlighted: Bool {
        didSet {
            layer.opacity = isHighlighted ? 0.6 : 1.0
        }
    }
    
    override var isSelected: Bool {
        didSet {
            checkmarkImageView.image = isSelected ? checkedImage : uncheckedImage
            checkmarkImageView.tintColor = isSelected ? .systemBlue : .systemGray
        }
    }
    
    // MARK: - Properties
    
    private let theme: UIUserInterfaceStyle
    private let completion: () -> Void
    
    // MARK: - Init
    
    required init(theme: UIUserInterfaceStyle, completion: @escaping () -> Void) {
        self.theme = theme
        self.completion = completion
        super.init(frame: .zero)
        setupButton()
        prepareButton()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Button
    
    private func setupButton() {
        addSubview(interfaceImageView)
        addSubview(label)
        addSubview(checkmarkImageView)
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    private func prepareButton() {
        switch theme {
        case .light:
            interfaceImageView.image = UIImage(named: "ThemeDayButton")
            label.text = "Day"
        case .dark:
            interfaceImageView.image = UIImage(named: "ThemeNightButton")
            label.text = "Night"
        default: break
        }
    }
    
    @objc
    private func buttonTapped() {
        isSelected = true
        completion()
    }
}

// MARK: - Setting Constraints

extension ThemesButton {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            interfaceImageView.topAnchor.constraint(equalTo: topAnchor),
            interfaceImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            interfaceImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            label.topAnchor.constraint(equalTo: interfaceImageView.bottomAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            checkmarkImageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            checkmarkImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkmarkImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            checkmarkImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
}
