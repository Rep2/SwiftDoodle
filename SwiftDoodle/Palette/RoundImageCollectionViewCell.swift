import UIKit

class RoundImageCollectionViewCell: UICollectionViewCell, Identifiable {
    @IBOutlet fileprivate weak var imageView: UIImageView!

    var longPressCallback: ((UILongPressGestureRecognizer) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.layer.cornerRadius = imageView.bounds.height / 2
        imageView.layer.masksToBounds = true

        backgroundColor = .clear

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RoundImageCollectionViewCell.longPressGesutreRecognizerWasActivated(gestureRecognizer:)))
        longPressGestureRecognizer.minimumPressDuration = 1

        contentView.addGestureRecognizer(longPressGestureRecognizer)
    }

    func present(color: UIColor, longPressCallback: @escaping (UILongPressGestureRecognizer) -> Void) {
        self.longPressCallback = longPressCallback

        imageView.image = UIImage.from(color: color, with: imageView.bounds.size)

        if let colorComponents = color.cgColor.components, colorComponents.count >= 3 {
            let inverseColor = UIColor(red: 1 - colorComponents[0], green: 1 - colorComponents[1], blue: 1 - colorComponents[2], alpha: 1)

            imageView.layer.borderColor = inverseColor.cgColor
        }
    }

    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 2.5 : 0
        }
    }

    @objc
    func longPressGesutreRecognizerWasActivated(gestureRecognizer: UILongPressGestureRecognizer) {
        longPressCallback?(gestureRecognizer)
    }
}
