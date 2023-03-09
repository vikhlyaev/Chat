import UIKit

final class ConversationViewController: UIViewController {
    
    private lazy var chatTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)
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
    
    private lazy var customNavBar: UIView = {
        let view = UIView()
        view.backgroundColor = .customBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var customBackButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var customTitleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var customPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var customNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let user: User
    
    init(user: User) {
        self.user = user
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
        addObserversKeyboard()
        hideKeyboardByTappingOnScreen()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addBottomBorder()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(customNavBar)
        customNavBar.addSubview(customBackButton)
        customNavBar.addSubview(customTitleView)
        customTitleView.addSubview(customPhotoImageView)
        customTitleView.addSubview(customNameLabel)
        view.addSubview(chatTableView)
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
        customPhotoImageView.image = user.photo
        customNameLabel.text = user.name
    }
    
    private func hideKeyboardByTappingOnScreen() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(textView.endEditing(_:))))
    }
    
    private func addObserversKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func addBottomBorder() {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: customNavBar.frame.height - 1, width: customNavBar.frame.width, height: 1)
        bottomBorder.backgroundColor = UIColor(red: 0.686, green: 0.686, blue: 0.694, alpha: 1).cgColor
        customNavBar.layer.addSublayer(bottomBorder)
    }
    
    private func convert(message: Message) -> MessageCellModel {
        return MessageCellModel(text: message.text,
                                date: message.date,
                                type: message.type)
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                view.frame.origin.y = view.frame.origin.y - keyboardSize.height
            }
        }
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    @objc
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
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sortedMessages = user.sortedMessage else { return nil }
        return sortedMessages[section].date.onlyDayAndMonth()
    }
    
    
}

// MARK: - UITableViewDelegate

extension ConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sortedMessages = user.sortedMessage else { return nil }
        let header = UITableViewHeaderFooterView()
        var content = header.defaultContentConfiguration()
        content.text = sortedMessages[section].date.onlyDayAndMonth()
        content.textProperties.font = .systemFont(ofSize: 11, weight: .medium)
        content.textProperties.alignment = .center
        content.textProperties.color = .customDarkGrey
        header.contentConfiguration = content
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        24
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
            
            customBackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
            customBackButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 16),
            customBackButton.widthAnchor.constraint(equalToConstant: 32),
            customBackButton.heightAnchor.constraint(equalToConstant: 32),
            
            customTitleView.centerXAnchor.constraint(equalTo: customNavBar.centerXAnchor),
            customTitleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            customPhotoImageView.centerXAnchor.constraint(equalTo: customTitleView.centerXAnchor),
            customPhotoImageView.topAnchor.constraint(equalTo: customTitleView.topAnchor),
            customPhotoImageView.widthAnchor.constraint(equalToConstant: 50),
            customPhotoImageView.heightAnchor.constraint(equalToConstant: 50),
            
            customNameLabel.centerXAnchor.constraint(equalTo: customTitleView.centerXAnchor),
            customNameLabel.topAnchor.constraint(equalTo: customPhotoImageView.bottomAnchor, constant: 5),
            
            chatTableView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            chatTableView.bottomAnchor.constraint(greaterThanOrEqualTo: wrapperView.topAnchor, constant: -4),
            
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
