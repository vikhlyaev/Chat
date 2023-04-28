import UIKit

final class PhotoSelectionViewController: UIViewController {
    
    private lazy var photosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let output: PhotoSelectionViewOutput
    
    // MARK: - Life Cycle
    
    init(output: PhotoSelectionViewOutput) {
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
        setupCollectionView()
        setDelegates()
        setupNavBar()
        output.viewIsReady()
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(photosCollectionView)
    }
    
    private func setupCollectionView() {
        photosCollectionView.register(PhotoSelectionCell.self, forCellWithReuseIdentifier: PhotoSelectionCell.reuseIdentifier)
    }
    
    private func setDelegates() {
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
    }
    
    private func setupNavBar() {
        title = "Select photo"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(cancelButtonTapped))
    }
    
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension PhotoSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        output.photosCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: PhotoSelectionCell.reuseIdentifier, for: indexPath) as? PhotoSelectionCell
        else {
            return UICollectionViewCell()
        }
        
        let photo = output.didRequestPhoto(by: indexPath.item)
        cell.configure(with: photo)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width / 3 - 1.5, height: collectionView.bounds.width / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        2
    }
}

// MARK: - UICollectionViewDelegate

extension PhotoSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("ho")
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastItemIndex = collectionView.numberOfItems(inSection: 0) - 1
        if indexPath.item == lastItemIndex {
            output.didLoadNextPhoto()
        }
    }
}

// MARK: - PhotoSelectionViewInput

extension PhotoSelectionViewController: PhotoSelectionViewInput {
    
}

// MARK: - Setting Constraints

extension PhotoSelectionViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            photosCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photosCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photosCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photosCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
