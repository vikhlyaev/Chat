import UIKit
import Combine

final class ChannelViewController: UIViewController {
    
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
        tableView.register(ChannelCell.self,
                           forCellReuseIdentifier: CellType.textSent.rawValue)
        tableView.register(ChannelCell.self,
                           forCellReuseIdentifier: CellType.textReceived.rawValue)
        tableView.register(ChannelImageCell.self,
                           forCellReuseIdentifier: CellType.imageSent.rawValue)
        tableView.register(ChannelImageCell.self,
                           forCellReuseIdentifier: CellType.imageReceived.rawValue)
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
    
    private lazy var sendPhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.addTarget(self, action: #selector(sendPhotoButtonTapped), for: .touchUpInside)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    private lazy var customNavBar = CustomNavBar(name: output.didRequestName(),
                                                 imageURL: output.didRequestLogoUrl(),
                                                 completion: backButtonTapped)
    
    private lazy var backButtonTapped = { [weak self] in
        self?.navigationController?.popViewController(animated: true)
        return
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let output: ChannelViewOutput
    
    // MARK: - Life Cycle
    
    init(output: ChannelViewOutput) {
        self.output = output
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
        output.viewIsReady()
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
        wrapperView.addSubview(sendPhotoButton)
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
        else { return }
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
    
    @objc
    private func sendMessageButtonTapped() {
        guard let text = textView.text else { return }
        output.didSendMessage(text: text)
        textView.text = nil
        sendMessageButton.isEnabled = false
    }
    
    @objc
    private func sendPhotoButtonTapped() {
        output.didOpenPhotoSelection()
    }
}

extension ChannelViewController: ChannelViewInput {
    func showAlert(_ alert: UIViewController) {
        present(alert, animated: true)
    }
    
    func updateTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.channelTableView.reloadData()
        }
    }
}

// MARK: - ChannelCellDelegate

extension ChannelViewController: ChannelPhotoCellDelegate {
    func didRecieveImage(by imageUrl: String, _ completion: @escaping (UIImage?) -> Void) {
        output.didRequestImage(by: imageUrl) { imageData in
            if let imageData {
                if let image = UIImage(data: imageData) {
                    completion(image)
                }
            }
        }
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
        output.didRequestNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        output.didRequestNumberOfRows(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cellTextSent = tableView.dequeueReusableCell(withIdentifier: CellType.textSent.rawValue,
                                                             for: indexPath) as? ChannelCell,
            let cellTextReceived = tableView.dequeueReusableCell(withIdentifier: CellType.textReceived.rawValue,
                                                                 for: indexPath) as? ChannelCell,
            let cellImageSent = tableView.dequeueReusableCell(withIdentifier: CellType.imageSent.rawValue,
                                                              for: indexPath) as? ChannelImageCell,
            let cellImageReceived = tableView.dequeueReusableCell(withIdentifier: CellType.imageSent.rawValue,
                                                                  for: indexPath) as? ChannelImageCell
        else {
            return UITableViewCell()
        }
        
        let (message, isLink) = output.didRequestMessage(for: indexPath)
        if isLink {
            if message.id == output.didRequestUserId() {
                cellImageSent.delegate = self
                cellImageSent.resetCell()
                cellImageSent.configure(cellType: .imageSent, with: message)
                return cellImageSent
            } else {
                cellImageReceived.delegate = self
                cellImageReceived.resetCell()
                cellImageReceived.configure(cellType: .imageReceived, with: message)
                return cellImageReceived
            }
        } else {
            if message.id == output.didRequestUserId() {
                cellTextSent.resetCell()
                cellTextSent.configure(cellType: .textSent, with: message)
                return cellTextSent
            } else {
                cellTextReceived.resetCell()
                cellTextReceived.configure(cellType: .textReceived, with: message)
                return cellTextReceived
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension ChannelViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = ChannelHeader(title: output.didRequestDate(inSection: section).onlyDayAndMonth())
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
            
            sendPhotoButton.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 14),
            sendPhotoButton.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -14),
            sendPhotoButton.widthAnchor.constraint(equalToConstant: 26),
            sendPhotoButton.heightAnchor.constraint(equalToConstant: 26),
            
            textView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -8),
            textView.leadingAnchor.constraint(equalTo: sendPhotoButton.trailingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -8),
            
            sendMessageButton.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -14),
            sendMessageButton.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -14),
            sendMessageButton.widthAnchor.constraint(equalToConstant: 26),
            sendMessageButton.heightAnchor.constraint(equalToConstant: 26)
        ])
    }
}

enum CellType: String {
    case textSent
    case textReceived
    case imageSent
    case imageReceived
}
