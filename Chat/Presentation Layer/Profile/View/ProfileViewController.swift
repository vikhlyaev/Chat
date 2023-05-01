import UIKit
import PhotosUI

final class ProfileViewController: UIViewController {
    
    // MARK: - Sections
    
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
    
    // MARK: - UI
    
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    
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
        setupTableView()
        setDelegates()
        setConstraints()
        hideKeyboardByTapOnView()
        output.viewIsReady()
    }
    
    // MARK: - Setup UI
    
    private func setupNavBar() {
        navigationItem.rightBarButtonItem = editButtonItem
        title = "Profile"
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(photoImageView)
        view.addSubview(addPhotoButton)
        view.addSubview(nameLabel)
        view.addSubview(informationLabel)
        view.addSubview(nameAndInformationTableView)
    }
    
    private func setupTableView() {
        nameAndInformationTableView.registerReusableCell(cellType: ProfileEditCell.self)
    }
    
    private func setDelegates() {
        nameAndInformationTableView.dataSource = self
    }
    
    // MARK: - Add Photo methods
    
    @objc
    private func addPhotoButtonTapped() {
        setEditing(true, animated: true)
        
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
    
    // MARK: - Keyboard methods
    
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
    
    // MARK: - TextField methods
    
    @objc
    private func textFieldValueChanged(_ textField: UITextField) {
        switch textField.tag {
        case TableViewSection.name.rawValue:
            nameLabel.text = textField.text
        case TableViewSection.information.rawValue:
            informationLabel.text = textField.text
        default:
            break
        }
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TableViewSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(cellType: ProfileEditCell.self)
        let indexLastCellInSection = TableViewSection.allCases.count - 1
        if indexPath.row == indexLastCellInSection {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        cell.textField.delegate = self
        cell.textField.tag = indexPath.row
        cell.configure(title: TableViewSection.allCases[indexPath.row].title, value: output.profileModel?[indexPath.row])
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
        output.didSaveProfile(
            ProfileModel(
                name: nameLabel.text,
                information: informationLabel.text,
                photo: photoImageView.image
            )
        )
        setEditing(false, animated: true)
    }
    
    @objc
    private func cancelButtonTapped() {
        setEditing(false, animated: true)
    }
}

// MARK: - ProfileViewInput

extension ProfileViewController: ProfileViewInput {
    func showController(_ controller: UIViewController) {
        present(controller, animated: true)
    }
    
    func startActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func updatePhoto(_ photo: UIImage) {
        photoImageView.image = photo
    }
    
    func showProfile(with model: ProfileModel) {
        nameLabel.text = model.name
        informationLabel.text = model.information
        photoImageView.image = model.photo
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Could not save profile", message: "Try again", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.setEditing(false, animated: true)
        }
        let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { [weak self] _ in
            self?.saveButtonTapped()
        }
        alert.addAction(okAction)
        alert.addAction(tryAgainAction)
        present(alert, animated: true)
    }
    
    func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "You are breathtaking", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        present(alert, animated: true)
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
