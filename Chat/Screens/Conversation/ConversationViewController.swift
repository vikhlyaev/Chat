import UIKit

final class ConversationViewController: UIViewController {
    
    private lazy var chatTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var wrapperView: WrapperView = {
        let view =  WrapperView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17)
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 36)
        textView.layer.cornerRadius = 18
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.36).cgColor
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var sendMessageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(sendMessageButtonTapped), for: .touchUpInside)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var customNavBar = CustomNavBar(name: user.name, photo: user.photo, completion: backButtonTapped)
    
    private let user: User
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = AppView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setDelegates()
        setConstraints()
        setupNavBar()
        addObserverKeyboard()
        hideKeyboardByTappingOnScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserverKeyboard()
    }
    
    private func setupView() {
        view.addSubview(chatTableView)
        view.addSubview(customNavBar)
        view.addSubview(wrapperView)
        wrapperView.addSubview(textView)
        wrapperView.addSubview(sendMessageButton)
    }
    
    private func setDelegates() {
        chatTableView.dataSource = self
        chatTableView.delegate = self
    }
    
    private func setupNavBar() {
        navigationController?.isNavigationBarHidden = true
    }
    
    private func hideKeyboardByTappingOnScreen() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(textView.endEditing(_:))))
    }
    
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
    
    private func convert(message: Message) -> MessageCellModel {
        return MessageCellModel(text: message.text,
                                date: message.date,
                                type: message.type)
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
    
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func sendMessageButtonTapped() {
        if let text = textView.text {
            print(text)
        }
    }
}

// MARK: - UITableViewDataSource

extension ConversationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sortedMessages = user.sortedMessage else { return 0 }
        return sortedMessages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sortedMessages = user.sortedMessage else { return 0 }
        return sortedMessages[section].messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.identifier,
                                                       for: indexPath) as? ConversationCell else { return UITableViewCell() }
        guard let message = user.sortedMessage?[indexPath.section].messages[indexPath.row] else { return UITableViewCell() }
        let model = convert(message: message)
        cell.resetCell()
        cell.configure(with: model)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sortedMessages = user.sortedMessage else { return nil }
        let header = ConversationsHeader(title: sortedMessages[section].date.onlyDayAndMonth())
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        32
    }
}

// MARK: - Setting Constraints

extension ConversationViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 137),
            
            chatTableView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: wrapperView.topAnchor, constant: -4),
            
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