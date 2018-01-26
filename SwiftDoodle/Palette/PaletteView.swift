import UIKit
import ChameleonFramework

public protocol PaletteViewEventHandler: class {
    func modelDidChange(viewModel: PaletteViewModel)
}

public final class PaletteView: UIView, FromNib {
    @IBOutlet fileprivate weak var drawToolSegmentedControl: UISegmentedControl!
    @IBOutlet fileprivate weak var drawWidthSlider: UISlider!
    @IBOutlet fileprivate weak var colorPickerImageView: UICollectionView!
    @IBOutlet fileprivate weak var undoButton: UIButton!

    var viewModel: PaletteViewModel?

    public weak var eventHandler: PaletteViewEventHandler?

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

        undoButton.tintColor = UIColor.flatSkyBlue
    }

    public func present(viewModel: PaletteViewModel) {
        self.viewModel = viewModel

        switch viewModel.tool {
        case .eraser:
            drawToolSegmentedControl.selectedSegmentIndex = 1
        default:
            drawToolSegmentedControl.selectedSegmentIndex = 0
        }

        drawWidthSlider.value = viewModel.width
    }

    @IBAction func widthSliderValueDidChange(_ sender: UISlider) {
        if let viewModel = viewModel {
            viewModel.width = sender.value

            eventHandler?.modelDidChange(viewModel: viewModel)
        }
    }

    @IBAction func didPressUndoButton(_ sender: Any) {
    }

    @IBAction func drawToolSelectedIndexValueChanged(_ sender: UISegmentedControl) {
        if let viewModel = viewModel {
            switch sender.selectedSegmentIndex {
            case 0:
                viewModel.tool = .pencil
            default:
                viewModel.tool = .eraser
            }

            eventHandler?.modelDidChange(viewModel: viewModel)
        }
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
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let viewModel = viewModel, let selectedColor = PaletteView.paletteColors.get(atIndex: indexPath.row) {
            viewModel.color = selectedColor

            viewModel.tool = .pencil
            drawToolSegmentedControl.selectedSegmentIndex = 0

            eventHandler?.modelDidChange(viewModel: viewModel)
        }
    }
}

extension PaletteView {
    static let paletteColors = [
        UIColor(hexString: "f23c17"),
        UIColor(hexString: "f2bcb1"),
        UIColor(hexString: "fcec41"),
        UIColor(hexString: "a4c459"),
        UIColor(hexString: "47a519"),
        UIColor(hexString: "1860ce"),
        UIColor(hexString: "7eabcb"),
        UIColor(hexString: "97744c"),
        UIColor(hexString: "ffffff"),
        UIColor(hexString: "000000")
        ].flatMap { $0 }
}
