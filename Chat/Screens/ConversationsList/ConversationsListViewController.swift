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
    
    private lazy var settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                      style: .plain,
                                                      target: self,
                                                      action: #selector(settingsButtonTapped))
    
    private lazy var photoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage.makeRandomAvatar(with: MockData.shared.user.name), for: .normal)
        button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var profileButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem()
        barButton.customView = photoButton
        return barButton
    }()
    
    private lazy var conversationsTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 24))
        tableView.separatorStyle = .none
        tableView.register(ConversationsListCell.self, forCellReuseIdentifier: ConversationsListCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var combineService = CombineService()
    
    private var photoUpdater: AnyCancellable?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        photoUpdater = combineService.photoPublisher
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photo in
                self?.photoButton.setBackgroundImage(photo, for: .normal)
            }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        navigationItem.leftBarButtonItem = settingsButton
        navigationItem.rightBarButtonItem = profileButton
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Chat"
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
    
    @objc private func settingsButtonTapped() {
        let settingViewController = SettingsViewController()
        navigationController?.pushViewController(settingViewController, animated: true)
    }
    
    @objc private func profileButtonTapped() {
        let profileViewController = ProfileViewController()
        navigationController?.present(UINavigationController(rootViewController: profileViewController), animated: true)
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        ConversationsListHeader(title: TableViewSection.allCases[section].title)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 24))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
}

// MARK: - UITableViewDataSource

extension ConversationsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        TableViewSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TableViewSection.allCases[section].array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationsListCell.identifier,
                                                       for: indexPath) as? ConversationsListCell else { return UITableViewCell() }
        let indexLastCellInSection = TableViewSection.allCases[indexPath.section].array.count - 1
        if indexPath.row == indexLastCellInSection {
            cell.customSeparator.isHidden = true
        }
        let currentUser = TableViewSection.allCases[indexPath.section].array[indexPath.row]
        let model = convert(user: currentUser)
        cell.resetCell()
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        TableViewSection.allCases[section].title
    }
}

// MARK: - Setting Constraints

extension ConversationsListViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            conversationsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            conversationsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            conversationsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            conversationsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            photoButton.widthAnchor.constraint(equalToConstant: 32),
            photoButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
}

