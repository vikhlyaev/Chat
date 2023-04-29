import UIKit

final class SettingsViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var settingsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.allowsSelection = false
        tableView.bounces = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
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
        setupView()
        setConstraints()
        setupNavBar()
        setupTableView()
        setDelegates()
    }
    
    // MARK: - Setup View
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(settingsTableView)
    }
    
    private func setupNavBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.backgroundColor = .clear
        title = "Settings"
    }
    
    private func setupTableView() {
        settingsTableView.registerReusableCell(cellType: ThemesCell.self)
    }
    
    private func setDelegates() {
        settingsTableView.dataSource = self
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(cellType: ThemesCell.self)
        cell.configureInitialState(currentTheme: output.currentTheme)
        cell.delegate = self
        return cell
    }
}

// MARK: - ThemesCellDelegate

extension SettingsViewController: ThemesCellDelegate {
    func didDayButtonTapped() {
        output.didButtonTapped(theme: .light)
    }
    
    func didNightButtonTapped() {
        output.didButtonTapped(theme: .dark)
    }
}

extension SettingsViewController: SettingsViewInput {}

// MARK: - Setting Constraints

extension SettingsViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            settingsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            settingsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            settingsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            settingsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
