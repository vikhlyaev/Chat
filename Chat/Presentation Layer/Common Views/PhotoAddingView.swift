import UIKit

final class PhotoAddingView: UIView {
    
    // MARK: - UI
    
    private lazy var wrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Photo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.addTarget(
            self,
            action: #selector(addPhotoButtonTapped),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let photoWidth: CGFloat
    private let addPhotoButtonAction: () -> Void
    
    // MARK: - Init
    
    init(
        photoWidth: CGFloat,
        addPhotoButtonAction: @escaping () -> Void
    ) {
        self.photoWidth = photoWidth
        self.addPhotoButtonAction = addPhotoButtonAction
        super.init(frame: .zero)
        
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photoImageView.layer.cornerRadius = photoWidth / 2
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(wrapperView)
        wrapperView.addSubview(photoImageView)
        wrapperView.addSubview(addPhotoButton)
    }
    
    // MARK: - Add Button actions
    
    @objc
    private func addPhotoButtonTapped() {
        addPhotoButtonAction()
    }
    
    func setPhoto(_ photo: UIImage?) {
        photoImageView.image = photo
    }
}

// MARK: - Settings Constraints

extension PhotoAddingView {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: topAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            photoImageView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            photoImageView.centerXAnchor.constraint(equalTo: wrapperView.centerXAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: photoWidth),
            photoImageView.heightAnchor.constraint(equalToConstant: photoWidth),
            
            addPhotoButton.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 24),
            addPhotoButton.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor),
            addPhotoButton.centerXAnchor.constraint(equalTo: wrapperView.centerXAnchor)
        ])
    }
}
