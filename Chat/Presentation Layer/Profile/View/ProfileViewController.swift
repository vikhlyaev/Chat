import UIKit
import PhotosUI

final class ProfileViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .appSecondaryBackground
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var photoAddingView = PhotoAddingView(photoWidth: 128) { [weak self] in
        self?.output.didOpenPhotoAddingAlertSheet()
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var informationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.alpha = 0.6
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 14
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var particleAnimation: ParticleAnimation?
    
    private var isAnimatesEditButton = false {
        didSet {
            if isAnimatesEditButton {
                stopEditButtonAnimation()
            } else {
                startEditButtonAnimation()
            }
        }
    }
    
    private let output: ProfileViewOutput
    
    // MARK: - Life Cycle
    
    init(output: ProfileViewOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupView()
        setConstraints()
        setupGestureRecognizers()
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        particleAnimation = ParticleAnimation(on: window)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        particleAnimation = nil
    }
    
    // MARK: - Setup UI
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "My profile"
        navigationController?.tabBarItem.title = "Profile"
    }
    
    private func setupView() {
        view.backgroundColor = .appBackground
        view.addSubview(wrapperView)
        wrapperView.addSubview(photoAddingView)
        wrapperView.addSubview(nameLabel)
        wrapperView.addSubview(informationLabel)
        wrapperView.addSubview(editButton)
    }
    
    private func setupGestureRecognizers() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressEditButton))
        longPressRecognizer.cancelsTouchesInView = true
        editButton.addGestureRecognizer(longPressRecognizer)
    }
    
    private func startEditButtonAnimation() {
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fromValue = -(CGFloat.pi / 180 * 18)
        rotate.toValue = CGFloat.pi / 180 * 18
        
        let moveUpDown = CAKeyframeAnimation(keyPath: "position.y")
        moveUpDown.values = [
            editButton.layer.position.y,
            editButton.layer.position.y - 5,
            editButton.layer.position.y + 5,
            editButton.layer.position.y
        ]
        moveUpDown.keyTimes = [0, 0.25, 0.75, 1]
        
        let moveLeftRight = CAKeyframeAnimation(keyPath: "position.x")
        moveLeftRight.values = [
            editButton.layer.position.x,
            editButton.layer.position.x + 5,
            editButton.layer.position.x - 5,
            editButton.layer.position.x
        ]
        moveLeftRight.keyTimes = [0, 0.25, 0.75, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.autoreverses = true
        animationGroup.repeatCount = .infinity
        animationGroup.duration = 0.3
        animationGroup.animations = [moveUpDown, moveLeftRight, rotate]
        
        editButton.layer.add(animationGroup, forKey: "EditAnimation")
    }
    
    private func stopEditButtonAnimation() {
        UIView.animate(withDuration: 2, delay: 0, options: [.beginFromCurrentState]) {
            self.editButton.layer.removeAllAnimations()
        }
    }
    
    @objc
    private func longPressEditButton(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == .began {
            isAnimatesEditButton = !isAnimatesEditButton
        } else {
            return
        }
    }
    
    // MARK: - Edit Button
    
    @objc
    private func editButtonTapped() {
        output.didOpenProfileEdit(with: self)
    }    
}

// MARK: - ProfileViewInput

extension ProfileViewController: ProfileViewInput {
    func updatePhoto(_ photo: UIImage) {
        photoAddingView.setPhoto(photo)
    }
    
    func showProfile(with model: ProfileModel) {
        nameLabel.text = model.name
        informationLabel.text = model.information
        photoAddingView.setPhoto(model.photo)
    }
    
    func showErrorAlert(with text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.setEditing(false, animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func showViewController(_ viewController: UIViewController) {
        present(viewController, animated: true)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension ProfileViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ProfileAnimator(transitionMode: .present,
                        duration: 1)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ProfileAnimator(transitionMode: .dismiss,
                        duration: 1)
    }
}

// MARK: - Setting Constraints

extension ProfileViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            wrapperView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            wrapperView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            photoAddingView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 32),
            photoAddingView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            photoAddingView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: photoAddingView.bottomAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -16),
            
            informationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            informationLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 16),
            informationLabel.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -16),
          
            editButton.topAnchor.constraint(equalTo: informationLabel.bottomAnchor, constant: 24),
            editButton.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 16),
            editButton.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -16),
            editButton.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -16),
            editButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
