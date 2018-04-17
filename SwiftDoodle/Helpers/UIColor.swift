import UIKit

extension UIColor {
    var invers: UIColor {
        guard let rgbColor = RGBColor(color: self) else {
            return .black
        }

        return UIColor(red: 1 - rgbColor.red, green: 1 - rgbColor.green, blue: 1 - rgbColor.blue, alpha: rgbColor.alpha)
    }
}
