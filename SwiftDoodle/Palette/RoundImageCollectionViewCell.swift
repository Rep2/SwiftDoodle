import UIKit

class RoundImageCollectionViewCell: UICollectionViewCell, Identifiable {
    @IBOutlet fileprivate weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.layer.cornerRadius = imageView.bounds.height / 2
        imageView.layer.masksToBounds = true

        backgroundColor = .clear
    }

    func present(color: UIColor) {
        imageView.image = UIImage.from(color: color, with: imageView.bounds.size)

        if color == .white {
            imageView.layer.borderColor = UIColor.lightGray.cgColor
            imageView.layer.borderWidth = 1
        }
    }
}
