import UIKit

final class ProfileEditViewController: UIViewController {
    
//    private enum TableViewSection: Int, CaseIterable {
//        case name, information
//        var title: String {
//            switch self {
//            case .name:
//                return "Name"
//            case .information:
//                return "Bio"
//            }
//        }
//    }
//
//    private lazy var nameAndInformationTableView: UITableView = {
//        let tableView = UITableView(frame: .zero)
//        tableView.layer.borderWidth = 0.33
//        tableView.layer.borderColor = UIColor.separator.cgColor
//        tableView.bounces = false
//        tableView.allowsSelection = false
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
//        tableView.rowHeight = 44
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        return tableView
//    }()
//
//    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let output: ProfileEditViewOutput
    
    // MARK: - Life Cycle
    
    init(output: ProfileEditViewOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setConstraints()
        setupNavBar()
//        setupTableView()
//        setDelegates()
        output.viewIsReady()
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        view.backgroundColor = .appBackground
    }
    
    private func setupNavBar() {
        let cancelButton = UIBarButtonItem(title: "Cancel",
                                           style: .plain,
                                           target: self,
                                           action: #selector(cancelButtonTapped))
        let saveButton = UIBarButtonItem(title: "Save",
                                         style: .plain,
                                         target: self,
                                         action: #selector(saveButtonTapped))
        navigationItem.setLeftBarButton(cancelButton, animated: true)
        navigationItem.setRightBarButton(saveButton, animated: true)
        title = "Edit Profile"
    }
    
//    private func setupTableView() {
//        nameAndInformationTableView.registerReusableCell(cellType: ProfileEditCell.self)
//    }
    
//    private func setDeledates() {
//        nameAndInformationTableView.dataSource = self
//    }
    
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
    
//    @objc
//    private func textFieldValueChanged(_ textField: UITextField) {
//        switch textField.tag {
//        case TableViewSection.name.rawValue:
//            //            nameLabel.text = textField.text
//            break
//        case TableViewSection.information.rawValue:
//            //            informationLabel.text = textField.text
//            break
//        default:
//            break
//        }
//    }
    
    // MARK: - Add Photo methods
    
//    @objc
//    private func addPhotoButtonTapped() {
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let takePhotoAction = UIAlertAction(title: "Take photo", style: .default) { [weak self] _ in
//            self?.output.didTakePhoto()
//        }
//        let chooseFromGalleryAction = UIAlertAction(title: "Choose from gallery", style: .default) { [weak self] _ in
//            self?.output.didChooseFromGallery()
//        }
//        let loadFromNetworkAction = UIAlertAction(title: "Load from network", style: .default) { [weak self] _ in
//            self?.output.didLoadFromNetwork()
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//        alert.addAction(takePhotoAction)
//        alert.addAction(chooseFromGalleryAction)
//        alert.addAction(loadFromNetworkAction)
//        alert.addAction(cancelAction)
//        present(alert, animated: true)
//    }

    @objc
    private func saveButtonTapped() {
//        view.endEditing(true)
//        let activityIndicatorBarButton = UIBarButtonItem(customView: activityIndicator)
//        navigationItem.setRightBarButton(activityIndicatorBarButton, animated: true)
//        output.didSaveProfile(
//            ProfileModel(
//                name: nameLabel.text,
//                information: informationLabel.text,
//                photo: photoImageView.image
//            )
//        )
//        setEditing(false, animated: true)
    }

    @objc
    private func cancelButtonTapped() {
//        setEditing(false, animated: true)
//        photoImageView.image = output.profileModel?.photo
//        guard
//            let nameCell = nameAndInformationTableView.visibleCells[0] as? ProfileEditCell,
//            let infoCell = nameAndInformationTableView.visibleCells[1] as? ProfileEditCell
//        else {
//            return
//        }
//        nameCell.textField.text = output.profileModel?.name
//        infoCell.textField.text = output.profileModel?.information
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

// extension ProfileEditViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        TableViewSection.allCases.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(cellType: ProfileEditCell.self)
//        let indexLastCellInSection = TableViewSection.allCases.count - 1
//        if indexPath.row == indexLastCellInSection {
//            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
//        }
//        cell.textField.delegate = self
//        cell.textField.tag = indexPath.row
//        cell.configure(title: TableViewSection.allCases[indexPath.row].title, value: output.profileModel?[indexPath.row])
//        return cell
//    }
// }

// MARK: - UITextFieldDelegate

// extension ProfileEditViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//    }
//
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        textField.addTarget(self, action: #selector(textFieldValueChanged), for: .editingDidEnd)
//    }
// }

// MARK: - ProfileEditViewInput

extension ProfileEditViewController: ProfileEditViewInput {
    
}

// MARK: - Setting Constraints

extension ProfileEditViewController {
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            
        ])
    }
    
}
