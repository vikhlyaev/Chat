import UIKit

final class ChannelImageCell: UITableViewCell {
    
    private lazy var wrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    weak var delegate: ChannelPhotoCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        contentView.addSubview(wrapperView)
        wrapperView.addSubview(photoImageView)
    }
    
    func resetCell() {
        photoImageView.image = nil
    }
    
    func configure(cellType: CellType, with imageUrl: String) {
       
    }
}

// MARK: - Setting Constraints

extension ChannelImageCell {
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: contentView.topAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            photoImageView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor),
            
            photoImageView.heightAnchor.constraint(equalToConstant: 150),
            photoImageView.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
}
