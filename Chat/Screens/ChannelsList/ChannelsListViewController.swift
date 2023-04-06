import UIKit
import Combine
import TFSChatTransport

final class ChannelsListViewController: UIViewController {
    
    private lazy var refreshControl = UIRefreshControl()
    
    private lazy var channelsTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.tableHeaderView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 73, bottom: 0, right: 0)
        tableView.register(ConversationsListCell.self, forCellReuseIdentifier: ConversationsListCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let chatService = ChatService(host: "167.235.86.234", port: 8080)
    private var channels: [Channel]? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.channelsTableView.reloadData()
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupView()
        setConstraints()
        setDelegates()
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        loadChannels()
    }
    
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
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        channelsTableView.refreshControl = refreshControl
    }
    
    private func setDelegates() {
        channelsTableView.delegate = self
        channelsTableView.dataSource = self
    }
    
    private func convert(channel: Channel) -> ChannelsListCellModel {
        
        ChannelsListCellModel(name: channel.name,
                              logoURL: channel.logoURL,
                              lastMessage: channel.lastMessage,
                              lastActivity: channel.lastActivity)
    }
    
    private func loadChannels() {
        chatService.loadChannels()
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.global(qos: .utility))
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("channels loaded")
                case .failure:
                    let alert = UIAlertController(title: "Error", message: "Could not load channels", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { [weak self] _ in
                        self?.loadChannels()
                    }
                    alert.addAction(okAction)
                    alert.addAction(tryAgainAction)
                    DispatchQueue.main.async { [weak self] in
                        self?.present(alert, animated: true)
                    }
                }
            } receiveValue: { [weak self] channels in
                self?.channels = channels.sorted { ($0.lastActivity ?? Date()) > ($1.lastActivity ?? Date()) }
            }
            .store(in: &cancellables)
    }
    
    private func createChannel(name: String, logoUrl: String? = nil) {
        chatService.createChannel(name: name, logoUrl: logoUrl)
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.global(qos: .utility))
            .sink { _ in
                print("channel created")
            } receiveValue: { [weak self] newChannel in
                self?.channels?.insert(newChannel, at: 0)
            }
            .store(in: &cancellables)
    }
    
    @objc
    private func addChannelTapped() {
        let alert = UIAlertController(title: "New channel", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let channelName = alert.textFields?.first?.text else { return }
            self?.createChannel(name: channelName)
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
    
    @objc
    private func handleRefreshControl() {
        refreshControl.endRefreshing()
        loadChannels()
    }
}

// MARK: - UITableViewDelegate

extension ChannelsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let channel = channels?[indexPath.row] else { return }
        let channelViewController = ChannelViewController(channel: channel)
        navigationController?.pushViewController(channelViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        76
    }
}

// MARK: - UITableViewDataSource

extension ChannelsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        channels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ConversationsListCell.identifier,
                                                     for: indexPath) as? ConversationsListCell,
            let channels = channels
        else {
            return UITableViewCell()
        }
        
        let indexLastCellInSection = channels.isEmpty ? 0 : channels.count - 1
        if indexPath.row == indexLastCellInSection {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        let model = convert(channel: channels[indexPath.row])
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
