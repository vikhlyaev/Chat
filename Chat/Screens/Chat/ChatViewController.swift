import UIKit
import OSLog

final class ChatViewController: UIViewController {

    private lazy var settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                      style: .plain,
                                                      target: self,
                                                      action: #selector(settingsButtonTapped))

    private lazy var profileButton = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"),
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(profileButtonTapped))
    
    private var user = User(name: "Stephen Johnson", position: "UX/UI designer, web designer", city: "Moscow, Russia")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupView()
    }
    
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
        let profileNavigationController = UINavigationController(rootViewController: ProfileViewController(user: user))
        navigationController?.present(profileNavigationController, animated: true)
    }
}

