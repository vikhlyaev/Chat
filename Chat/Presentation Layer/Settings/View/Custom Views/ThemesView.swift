import UIKit

final class ThemesView: UIView {
    
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
    
    weak var delegate: ThemesViewDelegate?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup View
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(themeButtonsStackView)
    }
    
    private func dayThemeButtonTapped() {
        nightThemeButton.isSelected = !dayThemeButton.isSelected
        delegate?.didDayButtonTapped()
    }
    
    private func nightThemeButtonTapped() {
        dayThemeButton.isSelected = !nightThemeButton.isSelected
        delegate?.didNightButtonTapped()
    }
    
    func setInitialState(currentTheme: UIUserInterfaceStyle) {
        dayThemeButton.isSelected = currentTheme == .light
        nightThemeButton.isSelected = !dayThemeButton.isSelected
    }
}

// MARK: - Setting Constraints

extension ThemesView {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            themeButtonsStackView.topAnchor.constraint(equalTo: topAnchor),
            themeButtonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            themeButtonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            themeButtonsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
