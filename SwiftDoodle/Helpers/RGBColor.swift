import UIKit

struct RGBColor {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat

    var color: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    init?(color: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}
