import UIKit
import ChameleonFramework

public protocol PaletteViewEventHandler: class {
    func modelDidChange(viewModel: PaletteViewModel)
}

public final class PaletteView: UIView, FromNib {
    @IBOutlet fileprivate weak var drawToolSegmentedControl: UISegmentedControl!
    @IBOutlet fileprivate weak var drawWidthSlider: UISlider!
    @IBOutlet fileprivate weak var colorPickerImageView: ColorPickerCollectionView!

    lazy var brushSizePreview: UIView = {
        let view = UIView()

        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        view.isHidden = true

        self.addSubview(view)

        return view
    }()

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

        brushSizePreview.snp.makeConstraints { make in
            make.height.width.equalTo(50)
            make.right.equalTo(self.snp.left).offset(-16)
            make.bottom.equalTo(self.snp.bottom).offset(-16)
        }

        colorPickerImageView.eventHandler = self

        drawWidthSlider
            .addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
    }

    @objc
    func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                guard let viewModel = viewModel else { return }

                brushSizePreview.isHidden = false

                brushSizePreview.backgroundColor = viewModel.color
                updateBrushSizePreview(to: viewModel.width)
            case .ended:
                brushSizePreview.isHidden = true
            default:
                break
            }
        }
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

            updateBrushSizePreview(to: viewModel.width)
        }
    }

    func updateBrushSizePreview(to size: Float) {
        brushSizePreview.snp.updateConstraints { make in
            make.height.width.equalTo(size)
            make.right.equalTo(self.snp.left).offset(-16 - (50 - size) / 2)
            make.bottom.equalTo(self.snp.bottom).offset(-16 - (50 - size) / 2)
        }

        brushSizePreview.layer.cornerRadius = CGFloat(size / 2)
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

extension PaletteView: ColorPickerCollectionViewEventHandler {
    public func didPreviews(color: UIColor) {
        brushSizePreview.isHidden = false
        updateBrushSizePreview(to: 54)

        brushSizePreview.backgroundColor = color
    }

    public func didEndPicking(color: UIColor) {
        brushSizePreview.isHidden = true

        if let viewModel = viewModel {
            viewModel.color = color

            viewModel.tool = .pencil
            drawToolSegmentedControl.selectedSegmentIndex = 0

            eventHandler?.modelDidChange(viewModel: viewModel)
        }
    }
}

extension PaletteView {
    static let paletteColors: [UIColor] = {
        return [
            UIColor.flatRed,
            UIColor.flatOrange,
            UIColor.flatYellow,
            UIColor.flatGreen,
            UIColor.flatMintDark,
            UIColor.flatSkyBlue,
            UIColor.flatBlueDark,
            UIColor.flatPurple,
            UIColor.white,
            UIColor.black
        ]
    }()
}
