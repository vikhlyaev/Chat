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
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 75
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Photo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(addPhotoButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
        output.viewIsReady()
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
        wrapperView.addSubview(photoImageView)
        wrapperView.addSubview(addPhotoButton)
        wrapperView.addSubview(nameLabel)
        wrapperView.addSubview(informationLabel)
        wrapperView.addSubview(editButton)
    }
    
    // MARK: - Add Photo methods
    
    @objc
    private func addPhotoButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take photo", style: .default) { [weak self] _ in
            self?.output.didTakePhoto()
        }
        let chooseFromGalleryAction = UIAlertAction(title: "Choose from gallery", style: .default) { [weak self] _ in
            self?.output.didChooseFromGallery()
        }
        let loadFromNetworkAction = UIAlertAction(title: "Load from network", style: .default) { [weak self] _ in
            self?.output.didLoadFromNetwork()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(takePhotoAction)
        alert.addAction(chooseFromGalleryAction)
        alert.addAction(loadFromNetworkAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    // MARK: - Edit Button
    
    @objc
    private func editButtonTapped() {
        output.didOpenProfileEdit(with: self)
    }
}

// MARK: - ProfileViewInput

extension ProfileViewController: ProfileViewInput {
    func showController(_ controller: UIViewController) {
        present(controller, animated: true)
    }
    
    func updatePhoto(_ photo: UIImage) {
        photoImageView.image = photo
    }
    
    func showProfile(with model: ProfileModel) {
        nameLabel.text = model.name
        informationLabel.text = model.information
        photoImageView.image = model.photo
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
    
    func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "You are breathtaking", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        present(alert, animated: true)
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
            
            photoImageView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 32),
            photoImageView.centerXAnchor.constraint(equalTo: wrapperView.centerXAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 150),
            photoImageView.heightAnchor.constraint(equalToConstant: 150),
            
            addPhotoButton.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 24),
            addPhotoButton.centerXAnchor.constraint(equalTo: wrapperView.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 24),
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
