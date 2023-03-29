import UIKit

final class SettingsViewController: UIViewController {
    
    private enum SettingsSection: CaseIterable {
        case themes
        
        var count: Int {
            switch self {
            case .themes:
                return 1
            }
        }
    }
    
    private lazy var settingsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ThemesCell.self, forCellReuseIdentifier: ThemesCell.identifier)
        return tableView
    }()
    
    private var themesManager: ThemesManagerProtocol
    
    init(themesManager: ThemesManagerProtocol = ThemesManager()) {
        self.themesManager = themesManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setConstraints()
        setDelegates()
        setupNavBar()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(settingsTableView)
    }
    
    private func setDelegates() {
        settingsTableView.dataSource = self
    }
    
    private func setupNavBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.backgroundColor = .clear
        title = "Settings"
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SettingsSection.allCases[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ThemesCell.identifier, for: indexPath) as? ThemesCell
        else {
            return UITableViewCell()
        }
        cell.delegate = self
        return cell
    }
}

// MARK: - ThemesCellDelegate

extension SettingsViewController: ThemesCellDelegate {
    func didDayButtonTapped() {
        themesManager.apply(theme: .light) { style in
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = style
        }
    }
    
    func didNightButtonTapped() {
        themesManager.apply(theme: .dark) { style in
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = style
        }
    }
}

// MARK: - Setting Constraints

extension SettingsViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            settingsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            settingsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            settingsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            settingsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
