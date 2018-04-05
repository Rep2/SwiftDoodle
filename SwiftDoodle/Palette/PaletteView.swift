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

    func didLongPressCellCallback(at indexPath: IndexPath) -> (UILongPressGestureRecognizer) -> Void {
        var startXPosition: Float!
        let initialColor = PaletteView.paletteColors.get(atIndex: indexPath.row)
        var shiftedColor: UIColor?

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

                strongSelf.brushSizePreview.isHidden = false
                strongSelf.brushSizePreview.backgroundColor = initialColor
                strongSelf.updateBrushSizePreview(to: 54)
            case .changed:
                let xChange = newXLocation - startXPosition
                let boundedSliderChange = max(min(xChange / (strongSelf.colorSaturationSliderWidth / 2), 1), -1)
                let shiftedSliderChange = (boundedSliderChange + 1) / 2

                shiftedColor = initialColor?.with(saturationOffset: CGFloat(shiftedSliderChange))
                strongSelf.brushSizePreview.backgroundColor = shiftedColor

                strongSelf.colorSaturationSlider.setValue(shiftedSliderChange, animated: true)
            case .ended, .cancelled, .failed:
                strongSelf.colorSaturationSlider.isHidden = true
                strongSelf.brushSizePreview.isHidden = true

                if let shiftedColor = shiftedColor, let viewModel = strongSelf.viewModel {
                    viewModel.color = shiftedColor

                    viewModel.tool = .pencil
                    strongSelf.drawToolSegmentedControl.selectedSegmentIndex = 0

                    strongSelf.eventHandler?.modelDidChange(viewModel: viewModel)
                }
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
