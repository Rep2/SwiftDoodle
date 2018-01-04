import UIKit

class RoundImageCollectionViewCell: UICollectionViewCell, Identifiable {
    @IBOutlet fileprivate weak var imageView: UIImageView!

    var selectedBorderColor: UIColor?
    var notSelectedBorderColor: UIColor?

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.layer.cornerRadius = imageView.bounds.height / 2
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.masksToBounds = true

        backgroundColor = .clear
    }

    func present(color: UIColor) {
        imageView.image = UIImage.from(color: color, with: imageView.bounds.size)

        notSelectedBorderColor = color == .white ? .lightGray : color
        selectedBorderColor = color == .black ? .lightGray : .black

        imageView.layer.borderColor = notSelectedBorderColor?.cgColor
        imageView.layer.borderWidth = 1
    }

    override var isSelected: Bool {
        didSet {
            imageView.layer.borderColor = isSelected ? selectedBorderColor?.cgColor : notSelectedBorderColor?.cgColor
        }
    }
}
