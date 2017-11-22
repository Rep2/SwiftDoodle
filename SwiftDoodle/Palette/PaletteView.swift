import UIKit
import ChameleonFramework

protocol PaletteViewEventHandler: class {
    func modelDidChange(model: PaletteViewModel)
}

public final class PaletteView: UIView, FromNib {
    @IBOutlet fileprivate weak var drawToolSegmentedControl: UISegmentedControl!
    @IBOutlet fileprivate weak var drawWidthSlider: UISlider!
    @IBOutlet fileprivate weak var colorPickerImageView: UICollectionView!

    weak var eventHandler: PaletteViewEventHandler?

    static let paletteColors = [
        UIColor.flatRed,
        UIColor.flatOrange,
        UIColor.flatYellow,
        UIColor.flatGreen,
        UIColor.flatSkyBlue,
        UIColor.flatCoffee,
        UIColor.flatPurple,
        UIColor.flatPink,
        UIColor.white,
        UIColor.black
    ]

    public override func awakeFromNib() {
        super.awakeFromNib()

        drawToolSegmentedControl.layer.cornerRadius = drawToolSegmentedControl.bounds.height / 2
        drawToolSegmentedControl.layer.borderWidth = 1
        drawToolSegmentedControl.layer.masksToBounds = true
        drawToolSegmentedControl.layer.borderColor = UIColor.flatSkyBlue.cgColor
        drawToolSegmentedControl.tintColor = UIColor.flatSkyBlue

        drawWidthSlider.tintColor = UIColor.flatSkyBlue

        layer.shadowOpacity = 0.3
        layer.cornerRadius = 10

        colorPickerImageView.registerNib(cellType: RoundImageCollectionViewCell.self)
    }

    public func present(viewModel: PaletteViewModel) {
        switch viewModel.tool {
        case .eraser:
            drawToolSegmentedControl.selectedSegmentIndex = 1
        default:
            drawToolSegmentedControl.selectedSegmentIndex = 0
        }

        drawWidthSlider.value = viewModel.width
    }
}

extension PaletteView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.cell(for: indexPath) as RoundImageCollectionViewCell

        if let color = PaletteView.paletteColors.get(atIndex: indexPath.row) {
            cell.present(color: color)
        }

        return cell
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension PaletteView: UICollectionViewDelegate {

}
