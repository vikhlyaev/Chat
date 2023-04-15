import UIKit
import Combine
import TFSChatTransport
import CoreData

final class ChannelsListViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var refreshControl = UIRefreshControl()
    private lazy var channelsTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.tableHeaderView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 73, bottom: 0, right: 0)
        tableView.register(ChannelsListCell.self, forCellReuseIdentifier: ChannelsListCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Services
    
    private let chatService = ChatService()
    
    // MARK: - DataSource
    
    private var dataSource: DataSourceProtocol?
    
    // MARK: - Combine
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        setupNavBar()
        setupView()
        setConstraints()
        setDelegates()
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(channelsTableView)
    }
    
    private func setupNavBar() {
        let addChannelsButton = UIBarButtonItem(title: "Add Channel",
                                                style: .plain,
                                                target: self,
                                                action: #selector(addChannelTapped))
        
        navigationItem.rightBarButtonItem = addChannelsButton
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Channels"
    }
    
    private func setupDataSource() {
        dataSource = DataSource(viewController: self,
                                entityName: Constants.CoreData.channelEntityName,
                                sortName: Constants.CoreData.channelSortName)
    }
    
    private func setDelegates() {
        channelsTableView.delegate = self
        channelsTableView.dataSource = self
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        channelsTableView.refreshControl = refreshControl
    }
    
    @objc
    private func handleRefreshControl() {
        refreshControl.endRefreshing()
    }
    
    @objc
    private func addChannelTapped() {
        let alert = UIAlertController(title: "New channel", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let channelName = alert.textFields?.first?.text else { return }
            self?.dataSource?.createChannel(name: channelName, logoUrl: nil)
        }
        createAction.isEnabled = false
        alert.addTextField { [weak self] textField in
            guard let self = self else { return }
            textField.placeholder = "Channel Name"
            textField.textPublisher()
                .map { $0 ?? "" }
                .sink { channelName in
                    let symbols = channelName.filter { $0.isNumber || $0.isLetter || $0.isSymbol || $0.isPunctuation }.count
                    if symbols != 0 {
                        createAction.isEnabled = true
                    } else {
                        createAction.isEnabled = false
                        textField.placeholder = "Enter the Channel Name"
                    }
                }
                .store(in: &self.cancellables)
        }
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension ChannelsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = dataSource?.getChannel(with: indexPath) else { return }
        let channelViewController = ChannelViewController(channel: model)
        navigationController?.pushViewController(channelViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        76
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let model = dataSource?.getChannel(with: indexPath) else { return }
            dataSource?.deleteChannel(with: model)
        }
    }
}

// MARK: - UITableViewDataSource

extension ChannelsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource?.getNumberOfRows(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let model = dataSource?.getChannel(with: indexPath),
            let cell = tableView.dequeueReusableCell(withIdentifier: ChannelsListCell.identifier,
                                                     for: indexPath) as? ChannelsListCell
        else {
            return UITableViewCell()
        }
        if indexPath.row == dataSource?.indexLastCellInSection(section: indexPath.section) {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        cell.resetCell()
        cell.configure(with: model)
        return cell
    }
}

// MARK: - Setting Constraints

extension ChannelsListViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            channelsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            channelsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            channelsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            channelsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
