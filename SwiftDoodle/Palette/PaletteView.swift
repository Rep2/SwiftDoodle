import UIKit
import ChameleonFramework

public protocol PaletteViewEventHandler: class {
    func modelDidChange(viewModel: PaletteViewModel)
}

public final class PaletteView: UIView, FromNib {
    @IBOutlet fileprivate weak var drawToolSegmentedControl: UISegmentedControl!
    @IBOutlet fileprivate weak var drawWidthSlider: UISlider!
    @IBOutlet fileprivate weak var colorPickerImageView: UICollectionView!

    lazy var brushSizePreview: UIView = {
        let view = UIView()

        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        view.isHidden = true

        self.addSubview(view)

        return view
    }()

    let colorSaturationSliderWidth: Float = 164

    lazy var colorSaturationSlider: UISlider = {
        let slider = UISlider()

        slider.isHidden = true
        slider.minimumValue = 0
        slider.maximumValue = 1

        self.addSubview(slider)

        slider.snp.makeConstraints { make in
            make.width.equalTo(colorSaturationSliderWidth)
            make.height.equalTo(50)
            make.centerX.equalTo(self)
            make.top.equalTo(self.snp.top).offset(-74)
        }

        return slider
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

extension PaletteView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.cell(for: indexPath) as RoundImageCollectionViewCell

        if let color = PaletteView.paletteColors.get(atIndex: indexPath.row) {
            cell.present(color: color, longPressCallback: didLongPressCellCallback(at: indexPath))
        }

        return cell
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func didLongPressCellCallback(at: IndexPath) -> (UILongPressGestureRecognizer) -> Void {
        var startXPosition: Float!

        return { [weak self] gestureRecognizer in
            guard let strongSelf = self else { return }

            let newXLocation = Float(gestureRecognizer.location(in: strongSelf).x)

            if startXPosition == nil {
                startXPosition = newXLocation
            }

            switch gestureRecognizer.state {
            case .began:
                strongSelf.colorSaturationSlider.isHidden = false
                strongSelf.colorSaturationSlider.value = 0.5

                if let viewModel = strongSelf.viewModel {
                    strongSelf.brushSizePreview.isHidden = false
                    strongSelf.brushSizePreview.backgroundColor = viewModel.color
                    strongSelf.updateBrushSizePreview(to: viewModel.width)
                }
            case .changed:
                let xChange = newXLocation - startXPosition
                let boundedSliderChange = max(min(xChange / (strongSelf.colorSaturationSliderWidth / 2), 1), -1)
                let shiftedSliderChange = (boundedSliderChange + 1) / 2

                strongSelf.colorSaturationSlider.setValue(shiftedSliderChange, animated: true)
            case .ended, .cancelled, .failed:
                strongSelf.colorSaturationSlider.isHidden = true
                strongSelf.brushSizePreview.isHidden = true
            default:
                break
            }
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

extension PaletteView {
    static let paletteColors: [UIColor] = {
        let color = UIColor(hexString: "ff0000")!

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
//            throw GenericError.error(text: "Failed to decode Command")
            return []
        }

        return stride(from: 0.2 as CGFloat, to: 1 as CGFloat, by: 0.08 as CGFloat)
            .map {
                if $0 < 0.5 {
                    return UIColor(red: red * $0 * 2, green: green * $0 * 2, blue: blue * $0 * 2, alpha: 1)
                } else {
                    let factor = 2 * ($0 - 0.5)

                    return UIColor(red: red + (1 - red) * factor, green: green + (1 - green) * factor, blue: blue + (1 - blue) * factor, alpha: 1)
                }
            }
    }()
}
