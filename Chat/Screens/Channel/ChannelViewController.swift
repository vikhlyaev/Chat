import UIKit
import Combine
import TFSChatTransport
import CoreData

final class ChannelViewController: UIViewController {
    
    private enum Constants: String {
        case channelCellSent
        case channelCellReceived
        case userName = "Anton Vikhlyaev"
    }
    
    // MARK: - UI
    
    private lazy var channelTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.bounces = false
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        tableView.register(ChannelCell.self, forCellReuseIdentifier: Constants.channelCellSent.rawValue)
        tableView.register(ChannelCell.self, forCellReuseIdentifier: Constants.channelCellReceived.rawValue)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var wrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17)
        textView.isScrollEnabled = false
        textView.text = "Type message"
        textView.textColor = .systemGray
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 36)
        textView.layer.cornerRadius = 18
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.separator.cgColor
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var sendMessageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(sendMessageButtonTapped), for: .touchUpInside)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var customNavBar = CustomNavBar(name: channel.name,
                                                 imageURL: channel.logoURL,
                                                 completion: backButtonTapped)
    
    private lazy var backButtonTapped = { [weak self] in
        self?.navigationController?.popViewController(animated: true)
        return
    }
    
    // MARK: - Services
    
    private lazy var dataSource: DataSourceProtocol = DataSource()
    
    // MARK: - Private properties
    
    private let channel: ChannelModel
    
    // MARK: - DataSource
    
    private var sortedMessages: [SortedMessage] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.channelTableView.reloadData()
            }
        }
    }
    
    // MARK: - Combine
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Life Cycle
    
    init(channel: ChannelModel) {
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setDelegates()
        setConstraints()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserverKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserverKeyboard()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        moveScrollIndicator()
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(channelTableView)
        view.addSubview(customNavBar)
        view.addSubview(wrapperView)
        wrapperView.addSubview(textView)
        wrapperView.addSubview(sendMessageButton)
    }
    
    private func setDelegates() {
        channelTableView.dataSource = self
        channelTableView.delegate = self
        textView.delegate = self
    }
    
    private func setupNavBar() {
        navigationController?.isNavigationBarHidden = true
    }
    
    private func moveScrollIndicator() {
        channelTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0,
                                                              left: 0.0,
                                                              bottom: 0.0,
                                                              right: channelTableView.bounds.size.width - 8.0)
    }
    
    // MARK: - Observers
    
    private func addObserverKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChange),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    private func removeObserverKeyboard() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillChangeFrameNotification,
                                                  object: nil)
    }
    
    @objc
    private func keyboardWillChange(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }
        
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)
        let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]
        let animationDuration: TimeInterval = (keyboardAnimationDuration as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: animationCurve,
                       animations: {
            self.additionalSafeAreaInsets.bottom = intersection.height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - Messages
    
    private func groupMessages(_ messages: [MessageModel]) -> [SortedMessage] {
        messages.daySorted
            .map { SortedMessage(date: $0.key, messages: $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    @objc
    private func sendMessageButtonTapped() {
        var userID: String {
            if let id = UserDataStorage.userID {
                return id
            } else {
                let id = "\(UUID())"
                UserDataStorage.userID = id
                return id
            }
        }
//        let userName = Constants.userName.rawValue
//        guard let text = textView.text else { return }
//        chatService.sendMessage(text: text, channelId: channel.id, userId: userID, userName: userName)
//            .subscribe(on: DispatchQueue.main)
//            .receive(on: DispatchQueue.global(qos: .utility))
//            .sink { [weak self] completion in
//                switch completion {
//                case .finished:
//                    print("message sended")
//                case .failure:
//                    let alert = UIAlertController(title: "Error", message: "Unable to send message", preferredStyle: .alert)
//                    let okAction = UIAlertAction(title: "OK", style: .default)
//                    let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { [weak self] _ in
//                        self?.sendMessageButtonTapped()
//                    }
//                    alert.addAction(okAction)
//                    alert.addAction(tryAgainAction)
//                    DispatchQueue.main.async { [weak self] in
//                        self?.present(alert, animated: true)
//                    }
//                }
//            } receiveValue: { [weak self] newMessage in
//                guard let self else { return }
//                let message = self.convert(message: newMessage)
//                if self.sortedMessages.isEmpty {
//                    let today = SortedMessage(date: Date(), messages: [message])
//                    self.sortedMessages.append(today)
//                } else {
//                    self.sortedMessages[0].addMessage(message)
//                }
//            }
//            .store(in: &cancellables)
//
//        textView.text = nil
//        sendMessageButton.isEnabled = false
    }
}

// MARK: - DataSourceDelegate

extension ChannelViewController: DataSourceDelegate {
    func didShowAlert(alert: UIAlertController) {
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension ChannelViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .systemGray {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type message"
            textView.textColor = .systemGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        let symbols = text.filter { $0.isNumber || $0.isLetter || $0.isSymbol || $0.isPunctuation }.count
        sendMessageButton.isEnabled = symbols != 0 ? true : false
    }
}

// MARK: - UITableViewDataSource

extension ChannelViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sortedMessages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sortedMessages[section].messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellSent = tableView.dequeueReusableCell(withIdentifier: Constants.channelCellSent.rawValue,
                                                           for: indexPath) as? ChannelCell else { return UITableViewCell() }
        guard let cellReceived = tableView.dequeueReusableCell(withIdentifier: Constants.channelCellReceived.rawValue,
                                                               for: indexPath) as? ChannelCell else { return UITableViewCell() }
        let message = sortedMessages[indexPath.section].messages[indexPath.row]

        if message.id == UserDataStorage.userID {
            cellSent.resetCell()
            cellSent.configure(with: message)
            return cellSent
        } else {
            cellReceived.resetCell()
            cellReceived.configure(with: message)
            return cellReceived
        }
    }
}

// MARK: - UITableViewDelegate

extension ChannelViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = ChannelHeader(title: sortedMessages[section].date.onlyDayAndMonth())
        footer.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        32
    }
}

// MARK: - Setting Constraints

extension ChannelViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 137),
            
            channelTableView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            channelTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            channelTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            channelTableView.bottomAnchor.constraint(equalTo: wrapperView.topAnchor, constant: -4),
            
            wrapperView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            wrapperView.heightAnchor.constraint(greaterThanOrEqualToConstant: 52),
            
            textView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -8),
            textView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -8),
            
            sendMessageButton.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -14),
            sendMessageButton.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -14),
            sendMessageButton.widthAnchor.constraint(equalToConstant: 26),
            sendMessageButton.heightAnchor.constraint(equalToConstant: 26)
        ])
    }
}
