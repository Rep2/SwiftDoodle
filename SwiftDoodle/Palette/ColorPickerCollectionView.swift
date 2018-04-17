import UIKit
import SnapKit

public protocol ColorPickerCollectionViewEventHandler: class {
    var colors: [UIColor] { get }

    func didPreviews(color: UIColor)
    func didEndPicking(color: UIColor)
}

extension ColorPickerCollectionViewEventHandler {
    public var colors: [UIColor] {
        return [
            UIColor.flatRed(),
            UIColor.flatOrange(),
            UIColor.flatYellow(),
            UIColor.flatGreen(),
            UIColor.flatMintColorDark(),
            UIColor.flatSkyBlue(),
            UIColor.flatBlueColorDark(),
            UIColor.flatPurple(),
            UIColor.white,
            UIColor.black
        ]
    }
}

public class ColorPickerCollectionView: UICollectionView {
    public weak var eventHandler: ColorPickerCollectionViewEventHandler? {
        didSet {
            guard let eventHandler = eventHandler else { return }

            self.colors = eventHandler.colors

            reloadData()
        }
    }

    public var colors = [UIColor]()

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
            make.left.equalTo(self)
            make.top.equalTo(self.snp.top).offset(-74)
        }

        return slider
    }()

    public override func layoutSubviews() {
        super.layoutSubviews()

        dataSource = self
        layer.masksToBounds = false

        registerCell(cellType: RoundImageCollectionViewCell.self)
    }
}

extension ColorPickerCollectionView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(colors.count)

        return colors.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.cell(for: indexPath) as RoundImageCollectionViewCell

        if let color = colors.get(atIndex: indexPath.row) {
            cell.present(color: color, longPressCallback: didLongPressCellCallback(at: indexPath))
        }

        return cell
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func didLongPressCellCallback(at indexPath: IndexPath) -> (UILongPressGestureRecognizer) -> Void {
        var startXPosition: Float!
        let initialColor = colors.get(atIndex: indexPath.row)
        var shiftedColor: UIColor?

        return { [weak self] gestureRecognizer in
            guard let strongSelf = self else { return }

            let newXLocation = Float(gestureRecognizer.location(in: strongSelf).x)

            if startXPosition == nil {
                startXPosition = newXLocation
            }

            switch gestureRecognizer.state {
            case .began:
                strongSelf.colorSaturationSlider.snp.updateConstraints { make in
                    make.left.equalTo(strongSelf).offset(gestureRecognizer.location(in: self).x - CGFloat(strongSelf.colorSaturationSliderWidth / 2))
                }

                strongSelf.colorSaturationSlider.isHidden = false
                strongSelf.colorSaturationSlider.value = 0.5

                strongSelf.selectItem(at: indexPath, animated: false, scrollPosition: .top)

                initialColor.flatMap { strongSelf.eventHandler?.didPreviews(color: $0) }
            case .changed:
                let xChange = newXLocation - startXPosition
                let boundedSliderChange = max(min(xChange / (strongSelf.colorSaturationSliderWidth / 2), 1), -1)
                let shiftedSliderChange = (boundedSliderChange + 1) / 2

                shiftedColor = initialColor?.with(saturationValue: CGFloat(shiftedSliderChange))

                strongSelf.colorSaturationSlider.setValue(shiftedSliderChange, animated: true)

                shiftedColor.flatMap { strongSelf.eventHandler?.didPreviews(color: $0) }
            case .ended, .cancelled, .failed:
                strongSelf.colorSaturationSlider.isHidden = true

                shiftedColor.flatMap { strongSelf.eventHandler?.didEndPicking(color: $0) }
            default:
                break
            }
        }
    }
}
