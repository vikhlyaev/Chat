import UIKit
import OSLog

final class ChatViewController: UIViewController {
    
    private var logger: Logger {
        if ProcessInfo.processInfo.environment.keys.contains("LOGGING") {
            return Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "VCLifeCycle")
        } else {
            return Logger(.disabled)
        }
    }
    
    private lazy var settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                      style: .plain,
                                                      target: self,
                                                      action: #selector(settingsButtonTapped))
    
    private lazy var profileButton = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"),
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(profileButtonTapped))
    
    // MARK: - ViewController lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logger.calledInfo()
        
        setupNavBar()
        setupView()
        setConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        logger.calledInfo()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logger.calledInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logger.calledInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logger.calledInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logger.calledInfo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logger.calledInfo()
    }
    
    // MARK: - Private methods
    
    private func setupView() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = settingsButton
        navigationItem.rightBarButtonItem = profileButton
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Chat"
    }
    
    @objc private func settingsButtonTapped() {
        print("settingsButtonTapped")
    }
    
    @objc private func profileButtonTapped() {
        let profileNavigationController = UINavigationController(rootViewController: ProfileViewController())
        navigationController?.present(profileNavigationController, animated: true)
    }
}

// MARK: - Setting Constraints

extension ChatViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            
        ])
    }
}

