import UIKit

final class PhotoSelectionViewController: UIViewController {
    
    private lazy var photosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var photosCollectionViewDataSource: UICollectionViewDiffableDataSource<Int, PhotoModel>?
    
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
        setupDiffableDataSource()
        setupInitialSnapshot()
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
    
    private func setupDiffableDataSource() {
        photosCollectionViewDataSource = UICollectionViewDiffableDataSource<Int, PhotoModel>(
            collectionView: photosCollectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                let cell = collectionView.dequeueReusableCell(cellType: PhotoSelectionCell.self, for: indexPath)
                cell.delegate = self
                cell.resetCell()
                cell.configure(with: itemIdentifier)
                return cell
            })
    }
    
    private func setupCollectionView() {
        photosCollectionView.register(PhotoSelectionCell.self, forCellWithReuseIdentifier: PhotoSelectionCell.reuseIdentifier)
    }
    
    private func setupInitialSnapshot() {
        var shapshot = NSDiffableDataSourceSnapshot<Int, PhotoModel>()
        shapshot.appendSections([0])
        photosCollectionViewDataSource?.apply(shapshot, animatingDifferences: false)
    }
    
    private func setDelegates() {
        photosCollectionView.dataSource = photosCollectionViewDataSource
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

// MARK: - PhotoSelectionCellDelegate

extension PhotoSelectionViewController: PhotoSelectionCellDelegate {
    func didRecievePhoto(for photoModel: PhotoModel, _ completion: @escaping (UIImage?) -> Void) {
        output.didRequestPhoto(by: photoModel) { image in
            completion(image)
        }
    }
    
    func didSelectPhoto() {
        
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
            output.loadPhoto()
        }
    }
}

// MARK: - PhotoSelectionViewInput

extension PhotoSelectionViewController: PhotoSelectionViewInput {
    func updatePhotos(_ photos: [PhotoModel]) {
        guard let photosCollectionViewDataSource else { return }
        var snapshot = photosCollectionViewDataSource.snapshot()
        snapshot.appendItems(photos, toSection: 0)
        photosCollectionViewDataSource.apply(snapshot, animatingDifferences: false)
    }
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
