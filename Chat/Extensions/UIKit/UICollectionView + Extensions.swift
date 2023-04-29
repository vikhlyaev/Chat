import UIKit

extension UICollectionViewCell: Reusable {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}

extension UICollectionView {
    func dequeueReusableCell<Cell: UICollectionViewCell & Reusable>(cellType: Cell.Type, for indexPath: IndexPath) -> Cell {
        (dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? Cell) ?? Cell()
    }

    func registerReusableCell<Cell: UICollectionViewCell & Reusable>(cellType: Cell.Type) {
        register(cellType, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
}
