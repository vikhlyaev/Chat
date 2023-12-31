import UIKit
import Combine

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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var channelsListDataSource: ChannelsListDataSource?
    private var cancellables = Set<AnyCancellable>()
    private let output: ChannelsListViewOutput
    
    // MARK: - Life Cycle
    
    init(output: ChannelsListViewOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupDiffableDataSource()
        setupInitialSnapshot()
        setupNavBar()
        setupView()
        setConstraints()
        setDelegates()
        setupRefreshControl()
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        output.didUpdateChannels()
    }
    
    // MARK: - Setup UI
    
    private func setupTableView() {
        channelsTableView.registerReusableCell(cellType: ChannelsListCell.self)
    }
    
    private func setupDiffableDataSource() {
        channelsListDataSource = ChannelsListDataSource(tableView: channelsTableView)
    }
    
    private func setupInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ChannelModel>()
        snapshot.appendSections([0])
        channelsListDataSource?.apply(snapshot, animatingDifferences: false)
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
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        channelsTableView.refreshControl = refreshControl
    }
    
    @objc
    private func handleRefreshControl() {
        output.didUpdateChannels()
        refreshControl.endRefreshing()
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
            self.output.didCreateChannel(with: channelName, and: nil)
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

// MARK: - ChannelsListViewInput

extension ChannelsListViewController: ChannelsListViewInput {
    func showChannels(_ channelModels: [ChannelModel]) {
        guard var snapshot = channelsListDataSource?.snapshot() else { return }
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(channelModels, toSection: 0)
        channelsListDataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func deleteChannel(with channelId: String) {
        guard
            var snapshot = channelsListDataSource?.snapshot(),
            let currentChannel = snapshot.itemIdentifiers.filter({ $0.id == channelId }).first
        else { return }
        snapshot.deleteItems([currentChannel])
        channelsListDataSource?.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UITableViewDelegate

extension ChannelsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let snapshot = channelsListDataSource?.snapshot()
        guard let model = snapshot?.itemIdentifiers[indexPath.row] else { return }
        output.didSelectChannel(with: model)
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
            self.output.didDeleteChannel(with: model)
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
