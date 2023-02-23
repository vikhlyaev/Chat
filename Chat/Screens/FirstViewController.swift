import UIKit
import OSLog

final class FirstViewController: UIViewController {
    
    private var logger: Logger {
        if ProcessInfo.processInfo.environment.keys.contains("LOGGING") {
            return Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "VCLifeCycle")
        } else {
            return Logger(.disabled)
        }
    }
    
    private lazy var goToSecondViewControllerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Перейти на второй экран", for: .normal)
        button.addTarget(self, action: #selector(goToSecondViewControllerButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - ViewController lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logger.calledInfo()
        
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
        title = "Первый экран"
        view.backgroundColor = .systemBackground
        view.addSubview(goToSecondViewControllerButton)
    }
    
    @objc private func goToSecondViewControllerButtonTapped() {
        let secondViewController = SecondViewController()
        navigationController?.pushViewController(secondViewController, animated: true)
    }
}

// MARK: - Setting Constraints

extension FirstViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            goToSecondViewControllerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goToSecondViewControllerButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

