import UIKit

public class PaletteView: UIView {
    public enum Location {
        case left
        case right
        case bottom

        func frame(containerSize: CGSize) -> CGRect {
            switch self {
            case .left:
                return CGRect(x: -perpendicularLength, y: 0, width: perpendicularLength, height: containerSize.height)
            case .right:
                return CGRect(x: containerSize.width + perpendicularLength, y: 0, width: perpendicularLength, height: containerSize.height)
            case .bottom:
                return CGRect(x: 0, y: containerSize.height + perpendicularLength, width: containerSize.width, height: perpendicularLength)
            }
        }

        var perpendicularLength: CGFloat {
            switch self {
            case .left, .right:
                return 100
            case .bottom:
                return 150
            }
        }
    }

    let location: Location

    public init(containerSize: CGSize, location: Location) {
        self.location = location

        super.init(frame: location.frame(containerSize: containerSize))
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
