import UIKit

extension UICollectionView {
    func registerNib<T: UICollectionViewCell>(cellType: T.Type) where T: Identifiable {
        register(UINib(nibName: cellType.identifier, bundle: Bundle(for: PaletteView.self)), forCellWithReuseIdentifier: cellType.identifier)
    }

    func cell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: Identifiable {
        if let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T {
            return cell
        } else {
            fatalError("Unable to dequeue cell of type \(T.self) with identifier \(T.identifier)")
        }
    }
}
