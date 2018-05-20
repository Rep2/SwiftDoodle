import UIKit

extension UICollectionView {
    func registerCell<T: UICollectionViewCell>(cellType: T.Type) {
        register(cellType, forCellWithReuseIdentifier: String(describing: cellType.self))
    }

    func cell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        if let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T {
            return cell
        } else {
            fatalError("Unable to dequeue cell of type \(String(describing: T.self))")
        }
    }
}
