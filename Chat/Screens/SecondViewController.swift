import UIKit

final class SecondViewController: UIViewController {
    
    private lazy var backToFirstViewControllerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вернуться на первый экран", for: .normal)
        button.addTarget(self, action: #selector(backToFirstViewControllerButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupView()
        setConstraints()
    }
    
    private func setupView() {
        title = "Второй экран"
        view.backgroundColor = .systemBackground
        view.addSubview(backToFirstViewControllerButton)
    }
    
    @objc private func backToFirstViewControllerButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Setting Constraints

extension SecondViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            backToFirstViewControllerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backToFirstViewControllerButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
