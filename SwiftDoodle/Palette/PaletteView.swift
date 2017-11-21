import UIKit
import ChameleonFramework

public final class PaletteView: UIView, FromNib {
    @IBOutlet fileprivate weak var drawToolSegmentedControl: UISegmentedControl!
    @IBOutlet fileprivate weak var drawWidthSlider: UISlider!
    @IBOutlet fileprivate weak var colorPickerImageView: UICollectionView!

    public override func awakeFromNib() {
        super.awakeFromNib()

        drawToolSegmentedControl.layer.cornerRadius = drawToolSegmentedControl.bounds.height / 2
        drawToolSegmentedControl.layer.borderWidth = 1
        drawToolSegmentedControl.layer.masksToBounds = true
        drawToolSegmentedControl.layer.borderColor = UIColor.flatSkyBlue.cgColor
        drawToolSegmentedControl.tintColor = UIColor.flatSkyBlue

        drawWidthSlider.tintColor = UIColor.flatSkyBlue
    }
}
