import UIKit

extension UIColor {
    func with(saturationValue saturation: CGFloat) -> UIColor {
        guard saturation >= 0 && saturation <= 1,
            let rgbColor = RGBColor(color: self) else { return self }

        if saturation < 0.5 {
            return UIColor(
                red: rgbColor.red * saturation * 2,
                green: rgbColor.green * saturation * 2,
                blue: rgbColor.blue * saturation * 2,
                alpha: rgbColor.alpha
            )
        } else {
            let factor = 2 * (saturation - 0.5)

            return UIColor(
                red: rgbColor.red + (1 - rgbColor.red) * factor,
                green: rgbColor.green + (1 - rgbColor.green) * factor,
                blue: rgbColor.blue + (1 - rgbColor.blue) * factor,
                alpha: rgbColor.alpha
            )
        }
    }
}
