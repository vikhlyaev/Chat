import UIKit
import PhotosUI
import Combine

final class ProfileViewController: UIViewController {
    
    private enum TableViewSection: Int, CaseIterable {
        case name, information
        var title: String {
            switch self {
            case .name:
                return "Name"
            case .information:
                return "Bio"
            }
        }
    }
    
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
    
    private lazy var nameAndInformationTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.layer.borderWidth = 0.33
        tableView.layer.borderColor = UIColor.separator.cgColor
        tableView.bounces = false
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.rowHeight = 44
        tableView.isHidden = true
        tableView.register(ProfileEditCell.self, forCellReuseIdentifier: ProfileEditCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var imagePicker: UIImagePickerController?
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    private var concurrencyService: ConcurrencyServiceProtocol = ConcurrencyService()
    private var cancellables = Set<AnyCancellable>()
    private var model: ProfileViewModel = ProfileViewModel() {
        didSet {
            configure(with: model)
            nameAndInformationTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfile()
        setupNavBar()
        setupView()
        setDelegates()
        setConstraints()
        hideKeyboardByTapOnView()
    }
    
    private func loadProfile() {
        concurrencyService
            .profilePublisher()
            .receive(on: DispatchQueue.main)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [ weak self ] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    print("profile loaded")
                case .failure:
                    self.configure(with: self.model)
                    let alert = UIAlertController(title: "User data not found",
                                                  message: "The default profile is loaded.",
                                                  preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                }
            } receiveValue: { [weak self] model in
                self?.model = model
            }
            .store(in: &cancellables)
    }
    
    private func setupNavBar() {
        navigationItem.rightBarButtonItem = editButtonItem
        title = "Profile"
    }
    
    private func setDelegates() {
        nameAndInformationTableView.dataSource = self
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(photoImageView)
        view.addSubview(addPhotoButton)
        view.addSubview(nameLabel)
        view.addSubview(informationLabel)
        view.addSubview(nameAndInformationTableView)
    }
    
    private func takePhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            chooseFromGallery()
            return
        }
        imagePicker = UIImagePickerController()
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
    
    private func updatePhoto(_ photo: UIImage) {
        photoImageView.image = photo
        model.photo = photo
        concurrencyService.photoSubject.send(photo)
    }
    
    private func hideKeyboardByTapOnView() {
        let tapScreen = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapScreen.cancelsTouchesInView = false
        view.addGestureRecognizer(tapScreen)
        
        let swipeScreen = UISwipeGestureRecognizer(target: self, action: #selector(hideKeyboard))
        swipeScreen.cancelsTouchesInView = false
        view.addGestureRecognizer(swipeScreen)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Could not save profile", message: "Try again", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.setEditing(false, animated: true)
            self.configure(with: self.model)
        }
        let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { [weak self] _ in
            self?.saveButtonTapped()
        }
        alert.addAction(okAction)
        alert.addAction(tryAgainAction)
        present(alert, animated: true)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "You are breathtaking", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    @objc
    private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc
    private func addPhotoButtonTapped() {
        setEditing(true, animated: true)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take photo", style: .default) { [weak self] _ in
            self?.takePhoto()
        }
        let chooseFromGalleryAction = UIAlertAction(title: "Choose from gallery", style: .default) { [weak self] _ in
            self?.chooseFromGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(takePhotoAction)
        alert.addAction(chooseFromGalleryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @objc
    private func textFieldValueChanged(_ textField: UITextField) {
        switch textField.tag {
        case TableViewSection.name.rawValue:
            textField.textPublisher()
                .assign(to: \.text, on: nameLabel)
                .store(in: &cancellables)
            model.name = textField.text
        case TableViewSection.information.rawValue:
            textField.textPublisher()
                .assign(to: \.text, on: informationLabel)
                .store(in: &cancellables)
            model.information = textField.text
        default:
            break
        }
    }
}

// MARK: - ConfigurableViewProtocol

extension ProfileViewController: ConfigurableViewProtocol {
    func configure(with model: ProfileViewModel) {
        nameLabel.text = model.name != nil ? model.name : "No name"
        informationLabel.text = model.information != nil ? model.information : "No bio specified"
        photoImageView.image = model.photo != nil ? model.photo : UIImage(named: "PlaceholderAvatar")
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            if let image = image as? UIImage {
                DispatchQueue.main.async { [weak self] in
                    self?.updatePhoto(image)
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imagePicker = imagePicker,
              let image = info[.originalImage] as? UIImage else { return }
        imagePicker.dismiss(animated: true, completion: nil)
        updatePhoto(image)
    }
}

// MARK: - UINavigationControllerDelegate

extension ProfileViewController: UINavigationControllerDelegate {}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TableViewSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileEditCell.identifier,
                                                     for: indexPath) as? ProfileEditCell
        else {
            return UITableViewCell()
        }
        
        let indexLastCellInSection = TableViewSection.allCases.count - 1
        if indexPath.row == indexLastCellInSection {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        cell.textField.delegate = self
        cell.textField.tag = indexPath.row
        cell.configure(title: TableViewSection.allCases[indexPath.row].title, value: model[indexPath.row])
        return cell
    }
}

// MARK: - UITextFieldDelegate

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.addTarget(self, action: #selector(textFieldValueChanged), for: .editingDidEnd)
    }
}

// MARK: - Editing State

extension ProfileViewController {
    private func updateUI(editing: Bool) {
        nameLabel.isHidden = editing
        informationLabel.isHidden = editing
        nameAndInformationTableView.isHidden = !editing
        view.backgroundColor = editing ? .systemGray6 : .systemBackground
    }
    
    private func updateNavBar(editing: Bool) {
        if editing {
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
            let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
            navigationItem.setLeftBarButton(cancelButton, animated: true)
            navigationItem.setRightBarButton(saveButton, animated: true)
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.setRightBarButton(editButtonItem, animated: true)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        updateNavBar(editing: editing)
        updateUI(editing: editing)
        if let cell = nameAndInformationTableView.visibleCells.first as? ProfileEditCell, editing {
            cell.textField.becomeFirstResponder()
        }
    }
    
    @objc
    private func saveButtonTapped() {
        view.endEditing(true)
        
        let activityIndicatorBarButton = UIBarButtonItem(customView: activityIndicator)
        navigationItem.setRightBarButton(activityIndicatorBarButton, animated: true)
        activityIndicator.startAnimating()
        
        concurrencyService.profileSubject.send(model)
        
        activityIndicator.stopAnimating()
        showSuccessAlert()
        setEditing(false, animated: true)
    }
    
    @objc
    private func cancelButtonTapped() {
        setEditing(false, animated: true)
        configure(with: model)
    }
}

// MARK: - Setting Constraints

extension ProfileViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            photoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 150),
            photoImageView.heightAnchor.constraint(equalToConstant: 150),
            
            addPhotoButton.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 24),
            addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            informationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            informationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            informationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nameAndInformationTableView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 24),
            nameAndInformationTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nameAndInformationTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nameAndInformationTableView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
}
