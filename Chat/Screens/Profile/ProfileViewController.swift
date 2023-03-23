import UIKit
import PhotosUI

final class ProfileViewController: UIViewController {
    
    private enum TableViewSection: Int, CaseIterable {
        case name
        case information
        
        var title: String {
            switch self {
            case .name:
                return "Name"
            case .information:
                return "Bio"
            }
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PlaceholderAvatar")
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
    
    private lazy var closeButton = UIBarButtonItem(title: "Close",
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(closeButtonTapped))
    
    private lazy var rightBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "ellipsis.circle")
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private var imagePicker: UIImagePickerController?
    private var concurrencyService: ConcurrencyServiceProtocol
    private var savedModel: ProfileViewModel = ProfileViewModel()
    private var displayModel: ProfileViewModel = ProfileViewModel() {
        didSet {
            configure(with: displayModel)
        }
    }
    
    init(concurrencyService: ConcurrencyServiceProtocol = GCDService()) {
        self.concurrencyService = concurrencyService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = editButtonItem
        title = "My Profile"
    }
    
    private func setDelegates() {
        nameAndInformationTableView.dataSource = self
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(photoImageView)
        scrollView.addSubview(addPhotoButton)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(informationLabel)
        scrollView.addSubview(nameAndInformationTableView)
    }
    
    private func loadProfile() {
        concurrencyService.loadProfile { [weak self] result in
            switch result {
            case .success(let model):
                self?.displayModel = model
            case .failure(let error):
                print(error)
            }
        }
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
    
    private func updatePhoto(_ photo: UIImage) {
        savedModel.photo = photo
        photoImageView.image = photo
    }
    
    private func hideKeyboardByTapOnView() {
        let tapScreen = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapScreen.cancelsTouchesInView = false
        view.addGestureRecognizer(tapScreen)
        
        let swipeScreen = UISwipeGestureRecognizer(target: self, action: #selector(hideKeyboard))
        swipeScreen.cancelsTouchesInView = false
        view.addGestureRecognizer(swipeScreen)
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
            savedModel.name = textField.text ?? ""
            nameLabel.text = savedModel.name
        case TableViewSection.information.rawValue:
            savedModel.information = textField.text ?? ""
            informationLabel.text = savedModel.information
        default:
            break
        }
    }
}

// MARK: - ConfigurableViewProtocol

extension ProfileViewController: ConfigurableViewProtocol {
    func configure(with model: ProfileViewModel) {
        nameLabel.text = model.name
        informationLabel.text = model.information
        if let photo = model.photo {
            photoImageView.image = photo
        }
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
                DispatchQueue.main.async { [weak self] in
                    self?.updatePhoto(image)
                }
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
        cell.configure(title: TableViewSection.allCases[indexPath.row].title)
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
            let cancelButton = UIBarButtonItem(title: "Cancel",
                                               style: .plain,
                                               target: self,
                                               action: #selector(cancelButtonTapped))
            
            let saveGCDAction = UIAction(title: "Save GCD") { [weak self] action in
                guard let self = self else { return }
                
                self.view.endEditing(true)
                
                let activityIndicatorBarButton = UIBarButtonItem(customView: self.activityIndicator)
                self.navigationItem.setRightBarButton(activityIndicatorBarButton, animated: true)
                self.activityIndicator.startAnimating()
                
                if self.savedModel.name != self.displayModel.name {
                    if let data = self.savedModel.name?.toData() {
                        self.concurrencyService.saveData(data, as: .name) { error in
                            if let error = error {
                                print(error)
                            }
                        }
                    }
                }
                
                if self.savedModel.information != self.displayModel.information {
                    if let data = self.savedModel.information?.toData() {
                        self.concurrencyService.saveData(data, as: .information) { error in
                            if let error = error {
                                print(error)
                            }
                        }
                    }
                }
                
                if self.savedModel.photo != self.displayModel.photo {
                    guard let data = self.savedModel.photo?.pngData() else { return }
                    self.concurrencyService.saveData(data, as: .photo) { error in
                        if let error = error {
                            print(error)
                        }
                    }
                }
                
                self.activityIndicator.stopAnimating()
                self.setEditing(false, animated: true)
            }
            
            let saveOperationAction = UIAction(title: "Save Operation") { action in
                print("Save Operation")
            }
            
            let saveMenu = UIMenu(children: [saveGCDAction, saveOperationAction])
            let menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"),
                                             menu: saveMenu)
            navigationItem.setLeftBarButton(cancelButton, animated: true)
            navigationItem.setRightBarButton(menuButton, animated: true)
        } else {
            navigationItem.setLeftBarButton(closeButton, animated: true)
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
    private func cancelButtonTapped() {
        setEditing(false, animated: true)
        configure(with: displayModel)
        concurrencyService.saveProfile(profile: displayModel) { error in
            if let error = error {
                print(error)
            }
        }
    }
}

// MARK: - Setting Constraints

extension ProfileViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        
            photoImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 88),
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
            informationLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            
            nameAndInformationTableView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 24),
            nameAndInformationTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nameAndInformationTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nameAndInformationTableView.heightAnchor.constraint(equalToConstant: 88)
        ])
    }
}
