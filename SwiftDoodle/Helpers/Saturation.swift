import UIKit

extension UIColor {
    func with(saturationOffset saturation: CGFloat) -> UIColor {
        let saturation = max(min(saturation, 1), 0)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return self
        }

        if saturation < 0.5 {
            return UIColor(red: red * saturation * 2, green: green * saturation * 2, blue: blue * saturation * 2, alpha: 1)
        } else {
            let factor = 2 * (saturation - 0.5)

            return UIColor(red: red + (1 - red) * factor, green: green + (1 - green) * factor, blue: blue + (1 - blue) * factor, alpha: 1)
        }
    }
}
