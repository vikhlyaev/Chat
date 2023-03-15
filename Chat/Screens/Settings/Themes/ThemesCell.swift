import UIKit

final class ThemesCell: UITableViewCell {
    
    static let identifier = String(describing: ThemesCell.self)
    
    private lazy var dayThemeButton = ThemesButton(theme: .day, completion: dayThemeButtonTapped)
    private lazy var nightThemeButton = ThemesButton(theme: .night, completion: nightThemeButtonTapped)
    
    private lazy var themeButtonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dayThemeButton, nightThemeButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    weak var delegate: ThemesCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(themeButtonsStackView)
    }
    
    private func dayThemeButtonTapped() {
        nightThemeButton.isSelected = !dayThemeButton.isSelected
        delegate?.didDayButtonTapped()
    }
    
    private func nightThemeButtonTapped() {
        dayThemeButton.isSelected = !nightThemeButton.isSelected
        delegate?.didNightButtonTapped()
    }
}

// MARK: - Setting Constraints

extension ThemesCell {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            themeButtonsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            themeButtonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            themeButtonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            themeButtonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
        ])
    }
}
