import UIKit

extension UIImage {
    static func from(color: UIColor, with size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }
}
