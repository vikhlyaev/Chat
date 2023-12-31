import UIKit

final class ProfileEditViewController: UIViewController {
    
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
    
    // MARK: - UI

    private lazy var photoAddingView = PhotoAddingView(photoWidth: 150) { [weak self] in
        self?.dismiss(animated: true) { [weak self] in
            self?.saveProfile()
            self?.output.didUpdatePhoto()
        }
    }
    
    private lazy var nameAndInformationTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.layer.borderWidth = 0.33
        tableView.layer.borderColor = UIColor.separator.cgColor
        tableView.bounces = false
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tableView.rowHeight = 44
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var cancelButton = UIBarButtonItem(title: "Cancel",
                                               style: .plain,
                                               target: self,
                                               action: #selector(cancelButtonTapped))
    
    private lazy var saveButton = UIBarButtonItem(title: "Save",
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(saveButtonTapped))

    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    
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
        setupNavBar()
        setupView()
        setupTableView()
        setDelegates()
        setConstraints()
        output.viewIsReady()
    }
    
    // MARK: - Setup UI
    
    private func setupNavBar() {
        navigationItem.setLeftBarButton(cancelButton, animated: true)
        navigationItem.setRightBarButton(saveButton, animated: true)
        title = "Edit Profile"
    }
    
    private func setupView() {
        view.backgroundColor = .appBackground
        view.addSubview(photoAddingView)
        view.addSubview(nameAndInformationTableView)
    }
    
    private func setupTableView() {
        nameAndInformationTableView.registerReusableCell(cellType: ProfileEditCell.self)
    }
    
    private func setDelegates() {
        nameAndInformationTableView.dataSource = self
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
    
    private func saveProfile() {
        guard
            let name = (nameAndInformationTableView.visibleCells[0] as? ProfileEditCell)?.textField.text,
            let info = (nameAndInformationTableView.visibleCells[1] as? ProfileEditCell)?.textField.text
        else { return }

        output.didSaveProfile(
            ProfileModel(
                name: name,
                information: info,
                photo: photoAddingView.getPhoto()
            )
        )
    }

    @objc
    private func saveButtonTapped() {
        
        saveProfile()
    }

    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

 extension ProfileEditViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TableViewSection.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(cellType: ProfileEditCell.self)
        let indexLastCellInSection = TableViewSection.allCases.count - 1
        if indexPath.row == indexLastCellInSection {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        cell.textField.tag = indexPath.row
        cell.configure(title: TableViewSection.allCases[indexPath.row].title, value: output.profileModel?[indexPath.row])
        return cell
    }
 }

// MARK: - ProfileEditViewInput

extension ProfileEditViewController: ProfileEditViewInput {
    func updatePhoto(_ photo: UIImage) {
        photoAddingView.setPhoto(photo)
    }
    
    func showController(_ controller: UIViewController) {
        present(controller, animated: true)
    }
    
    func showAlert(_ alert: UIViewController) {
        present(alert, animated: true)
    }
    
    func startActivityIndicator() {
        activityIndicator.startAnimating()
        navigationItem.setRightBarButton(UIBarButtonItem(customView: activityIndicator), animated: true)
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        navigationItem.setRightBarButton(saveButton, animated: true)
    }
}

// MARK: - Setting Constraints

extension ProfileEditViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            photoAddingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            photoAddingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoAddingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            nameAndInformationTableView.topAnchor.constraint(equalTo: photoAddingView.bottomAnchor, constant: 24),
            nameAndInformationTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nameAndInformationTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nameAndInformationTableView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
}
