import UIKit
import Combine

final class ConversationsListViewController: UIViewController {
    
    private enum TableViewSection: CaseIterable {
        case online
        case history
        
        var title: String {
            switch self {
            case .online:
                return "Online".uppercased()
            case .history:
                return "History".uppercased()
            }
        }
        
        var array: [User] {
            switch self {
            case .online:
                return MockData.shared.users.filter { $0.isOnline == true }
            case .history:
                return MockData.shared.users.filter {
                    $0.isOnline == false && ($0.messages != nil || $0.messages?.isEmpty ?? false)
                }
            }
        }
    }
    
    private lazy var conversationsTableView: UITableView = {
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
    
    private lazy var concurrencyService: ConcurrencyServiceProtocol = ConcurrencyService()
    
    private var cancellable: Cancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupView()
        setConstraints()
        setDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(conversationsTableView)
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
    
    private func setDelegates() {
        conversationsTableView.delegate = self
        conversationsTableView.dataSource = self
    }
    
    private func convert(user: User) -> ConversationsListCellModel {
        return ConversationsListCellModel(name: user.name,
                                          message: user.messages?.last?.text,
                                          date: user.messages?.last?.date,
                                          isOnline: user.isOnline,
                                          hasUnreadMessages: user.hasUnreadMessages,
                                          photo: user.photo)
    }
    
    @objc private func addChannelTapped() {
        print(#function)
    }
}

// MARK: - UITableViewDelegate

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = TableViewSection.allCases[indexPath.section].array[indexPath.row]
        let conversationViewController = ConversationViewController(user: user)
        navigationController?.pushViewController(conversationViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        76
    }
}

// MARK: - UITableViewDataSource

extension ConversationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TableViewSection.allCases[section].array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationsListCell.identifier,
                                                       for: indexPath) as? ConversationsListCell
        else { return UITableViewCell() }
        
        let indexLastCellInSection = TableViewSection.allCases[indexPath.section].array.count - 1
        if indexPath.row == indexLastCellInSection {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }

        let currentUser = TableViewSection.allCases[indexPath.section].array[indexPath.row]
        let model = convert(user: currentUser)
        cell.resetCell()
        cell.configure(with: model)
        return cell
    }
}

// MARK: - Setting Constraints

extension ConversationsListViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            conversationsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            conversationsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            conversationsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            conversationsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
