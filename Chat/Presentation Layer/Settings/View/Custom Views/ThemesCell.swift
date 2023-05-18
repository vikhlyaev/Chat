import UIKit

final class ThemesCell: UITableViewCell {
    
    // MARK: - UI
    
    private lazy var themeButtonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dayThemeButton, nightThemeButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var dayThemeButton = ThemesButton(theme: .light, completion: dayThemeButtonTapped)
    private lazy var nightThemeButton = ThemesButton(theme: .dark, completion: nightThemeButtonTapped)
    
    weak var delegate: ThemesCellDelegate?
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup View
    
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
    
    func configureInitialState(currentTheme: UIUserInterfaceStyle) {
        dayThemeButton.isSelected = currentTheme == .light
        nightThemeButton.isSelected = !dayThemeButton.isSelected
//
//        switch currentTheme {
//        case .light:
//            dayThemeButton.isSelected = true
//            nightThemeButton.isSelected = false
//        case .dark:
//            dayThemeButton.isSelected = false
//            nightThemeButton.isSelected = true
//        default:
//            dayThemeButton.isSelected = false
//            nightThemeButton.isSelected = false
//        }
    }
}

// MARK: - Setting Constraints

extension ThemesCell {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            themeButtonsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            themeButtonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            themeButtonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            themeButtonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
}
