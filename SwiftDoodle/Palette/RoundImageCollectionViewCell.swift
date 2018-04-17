import SnapKit
import UIKit

open class RoundImageCollectionViewCell: UICollectionViewCell, Identifiable {
    open lazy var imageView: UIImageView = {
        let imageView = UIImageView()

        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    open var color: UIColor?
    var longPressCallback: ((UILongPressGestureRecognizer) -> Void)?

    open override func layoutSubviews() {
        super.layoutSubviews()

        addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        backgroundColor = .clear

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(RoundImageCollectionViewCell.longPressGesutreRecognizerWasActivated(gestureRecognizer:)))
        longPressGestureRecognizer.minimumPressDuration = 1

        contentView.addGestureRecognizer(longPressGestureRecognizer)
    }

    open func present(color: UIColor, cornerRadius: CGFloat, longPressCallback: @escaping (UILongPressGestureRecognizer) -> Void) {
        self.longPressCallback = longPressCallback
        self.color = color

        imageView.image = UIImage.from(color: color, with: contentView.bounds.size)
        imageView.layer.cornerRadius = cornerRadius
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = color.invers.cgColor

        if color == .white {
            imageView.layer.borderWidth = 2.5
        }
    }

    open override var isSelected: Bool {
        didSet {
            guard color != .white else {
                imageView.layer.borderWidth = 2.5

                return
            }

            imageView.layer.borderWidth = isSelected ? 2.5 : 0
        }
    }

    @objc
    func longPressGesutreRecognizerWasActivated(gestureRecognizer: UILongPressGestureRecognizer) {
        longPressCallback?(gestureRecognizer)
    }
}
