import UIKit

final class SettingsViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .appSecondaryBackground
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var themesView = ThemesView()
    
    // MARK: - Output
    
    private var output: SettingsViewOutput
    
    // MARK: - Init
    
    init(output: SettingsViewOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupView()
        setDelegates()
        setConstraints()
        output.viewIsReady()
    }
    
    // MARK: - Setup View
    
    private func setupView() {
        view.backgroundColor = .appBackground
        view.addSubview(wrapperView)
        wrapperView.addSubview(themesView)
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .clear
        title = "Settings"
    }
    
    private func setDelegates() {
        themesView.delegate = self
    }
}

// MARK: - SettingsViewInput

extension SettingsViewController: SettingsViewInput {
    func setInitialState(currentTheme: UIUserInterfaceStyle) {
        themesView.setInitialState(currentTheme: currentTheme)
    }
}

// MARK: - ThemesViewDelegate

extension SettingsViewController: ThemesViewDelegate {
    func didDayButtonTapped() {
        output.didButtonTapped(theme: .light)
    }
    
    func didNightButtonTapped() {
        output.didButtonTapped(theme: .dark)
    }
}

// MARK: - Setting Constraints

extension SettingsViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            wrapperView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            wrapperView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            themesView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 24),
            themesView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            themesView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
            themesView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -24)
        ])
    }
}
