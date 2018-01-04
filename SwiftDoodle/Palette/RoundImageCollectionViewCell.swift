import UIKit

class RoundImageCollectionViewCell: UICollectionViewCell, Identifiable {
    @IBOutlet fileprivate weak var imageView: UIImageView!
    var presentedColor: UIColor?

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.layer.cornerRadius = imageView.bounds.height / 2
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.masksToBounds = true

        backgroundColor = .clear
    }

    func present(color: UIColor) {
        presentedColor = color

        imageView.image = UIImage.from(color: color, with: imageView.bounds.size)

        if color == .white {
            imageView.layer.borderColor = UIColor.lightGray.cgColor
            imageView.layer.borderWidth = 1
        }
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                imageView.layer.borderWidth = 1
            } else {
                imageView.layer.borderWidth = 0
            }
        }
    }
}
