import UIKit
import PhotosUI
import OSLog

final class ProfileViewController: UIViewController {
    
    private var logger: Logger {
        if ProcessInfo.processInfo.environment.keys.contains("LOGGING") {
            return Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "ProfileVCLifeCycle")
        } else {
            return Logger(.disabled)
        }
    }
    
    private lazy var avatarPlaceholder = UIImage(named: "AvatarPlaceholder")
    
    private lazy var initialsLabel: UILabel = {
        let label = UILabel()
        label.text = initials
        label.font = .rounded(ofSize: 64, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = avatarPlaceholder
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
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
        label.text = "Stephen Johnson"
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var positionLabel: UILabel = {
        let label = UILabel()
        label.text = "UX/UI designer, web designer"
        label.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.text = "Moscow, Russia"
        label.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var closeButton = UIBarButtonItem(title: "Close",
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(closeButtonTapped))
    
    private var initials: String {
        guard let name = nameLabel.text else { return "" }
        return name.split(separator: " ").compactMap { String($0).first }.map { String($0) }.joined()
    }
    
    private var imagePicker: UIImagePickerController?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupView()
        setConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
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
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(avatarImageView)
        view.addSubview(addPhotoButton)
        view.addSubview(nameLabel)
        view.addSubview(positionLabel)
        view.addSubview(cityLabel)
        
        if avatarImageView.image == avatarPlaceholder {
            addInitials()
        }
    }
    
    private func addInitials() {
        avatarImageView.addSubview(initialsLabel)
        initialsLabel.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor).isActive = true
        initialsLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor).isActive = true
    }
    
    private func removeInitials() {
        initialsLabel.removeFromSuperview()
        initialsLabel.removeConstraints([
            initialsLabel.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = editButtonItem
        title = "My Profile"
    }
    
    private func takePhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            chooseFromGallery()
            return
        }
        imagePicker =  UIImagePickerController()
        guard let imagePicker = imagePicker else { return }
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.cameraDevice = .front
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func chooseFromGallery() {
        let configuration = PHPickerConfiguration()
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func updateAvatar(_ image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.avatarImageView.image = image
            self?.removeInitials()
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func addPhotoButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Сделать фото", style: .default) { [weak self] _ in
            self?.takePhoto()
        }
        let chooseFromGalleryAction = UIAlertAction(title: "Выбрать из галереи", style: .default) { [weak self] _ in
            self?.chooseFromGallery()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(takePhotoAction)
        alert.addAction(chooseFromGalleryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            if let image = image as? UIImage {
                self?.updateAvatar(image)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let imagePicker = imagePicker,
              let image = info[.originalImage] as? UIImage else { return }
        imagePicker.dismiss(animated: true, completion: nil)
        updateAvatar(image)
    }
}

// MARK: - UINavigationControllerDelegate

extension ProfileViewController: UINavigationControllerDelegate {
    
}

// MARK: - Setting Constraints

extension ProfileViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 150),
            avatarImageView.heightAnchor.constraint(equalToConstant: 150),
            avatarImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addPhotoButton.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 24),
            addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 24),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            positionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            positionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cityLabel.topAnchor.constraint(equalTo: positionLabel.bottomAnchor),
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
