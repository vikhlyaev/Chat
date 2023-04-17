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
    
    // MARK: - DataSource
    
    private lazy var dataSource = DataSource()
    
    // MARK: - DiffableDataSource
    
    private var channelsListDataSource: ChannelsListDataSource?
    
    // MARK: - Combine
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDiffableDataSource()
        setupInitialSnapshot()
        getChannels()
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
    
    private func setupInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ChannelModel>()
        snapshot.appendSections([0])
        channelsListDataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupDiffableDataSource() {
        channelsListDataSource = ChannelsListDataSource(tableView: channelsTableView)
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
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(channelsTableView)
    }
    
    private func setDelegates() {
        channelsTableView.delegate = self
        channelsTableView.dataSource = channelsListDataSource
        dataSource.delegate = self
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        channelsTableView.refreshControl = refreshControl
    }
    
    @objc
    private func handleRefreshControl() {
        refreshControl.endRefreshing()
        getChannels()
    }
    
    // MARK: - Data Source Publisher
    
    private func getChannels() {
        dataSource.channelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newChannelModels in
                guard var snapshot = self?.channelsListDataSource?.snapshot() else { return }
                newChannelModels.forEach { newChannel in
                    if snapshot.itemIdentifiers.contains(newChannel) {
                        return
                    }
                    snapshot.appendItems([newChannel])
                }
                self?.channelsListDataSource?.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Add Channel
    
    @objc
    private func addChannelTapped() {
        let alert = UIAlertController(title: "New channel", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard
                let self = self,
                let channelName = alert.textFields?.first?.text
            else { return }
            self.dataSource.createChannelInNetwork(name: channelName, logoUrl: nil)
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

// MARK: - DataSourceDelegate

extension ChannelsListViewController: DataSourceDelegate {
    func didShowAlert(alert: UIAlertController) {
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension ChannelsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let snapshot = channelsListDataSource?.snapshot()
        guard let model = snapshot?.itemIdentifiers[indexPath.row] else { return }
        let channelViewController = ChannelViewController(channel: model)
        navigationController?.pushViewController(channelViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        76
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            completion(true)
            guard
                let self = self,
                var snapshot = self.channelsListDataSource?.snapshot()
            else { return }
            let model = snapshot.itemIdentifiers[indexPath.row]
            snapshot.deleteItems([model])
            self.channelsListDataSource?.apply(snapshot)
            self.dataSource.deleteChannelFromNetwork(with: model)
            self.dataSource.deleteChannelFromStorage(with: model)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
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
