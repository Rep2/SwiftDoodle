class LinePoint: NSObject {

    struct PointType: OptionSet {
        let rawValue: Int

        static let Standard = PointType(rawValue: 0)
        static let Coalesced = PointType(rawValue: 1 << 0)
        static let Predicted = PointType(rawValue: 1 << 1)
        static let NeedsUpdate = PointType(rawValue: 1 << 2)
        static let Updated = PointType(rawValue: 1 << 3)
        static let Cancelled = PointType(rawValue: 1 << 4)
        static let Finger = PointType(rawValue: 1 << 5)

        static let touchUpdateProperties: [UITouchProperties] = [.altitude, .azimuth, .location]
    }

    // MARK: Properties

    var sequenceNumber: Int
    let timestamp: TimeInterval
    var location: CGPoint
    let type: UITouchType
    var altitudeAngle: CGFloat
    var azimuthAngle: CGFloat
    let estimationUpdateIndex: NSNumber?

    var pointType: PointType

    var drawWidth: CGFloat = 10

    // MARK: Initialization

    init(touch: UITouch, sequenceNumber: Int, pointType: PointType) {
        self.sequenceNumber = sequenceNumber
        self.type = touch.type
        self.pointType = pointType

        let view = touch.view
        location = touch.preciseLocation(in: view)
        azimuthAngle = touch.azimuthAngle(in: view)
        altitudeAngle = touch.altitudeAngle
        timestamp = touch.timestamp

        estimationUpdateIndex = touch.estimationUpdateIndex
    }
}

// MARK: Convenience

extension LinePoint {
    var centerRect: CGRect {
        return CGRect(origin: location, size: .zero)
    }

    var drawRect: CGRect {
        return centerRect
            .insetBy(dx: -drawWidth, dy: -drawWidth)
    }

    func drawRect(withPreviousPoint previousPoint: LinePoint) -> CGRect {
        return centerRect
            .union(previousPoint.centerRect)
            .insetBy(dx: -drawWidth, dy: -drawWidth)
    }

    var drawColor: UIColor {
        if pointType.contains(.Cancelled) {
            return .clear
        } else if pointType.contains(.Predicted) {
            return UIColor.black.withAlphaComponent(0.5)
        } else {
            return .black
        }
    }
}
