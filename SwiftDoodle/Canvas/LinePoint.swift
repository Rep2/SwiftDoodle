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
    var estimatedPropertiesExpectingUpdates: UITouchProperties
    var estimatedProperties: UITouchProperties
    let type: UITouchType
    var altitudeAngle: CGFloat
    var azimuthAngle: CGFloat
    let estimationUpdateIndex: NSNumber?

    var pointType: PointType

    var drawWidth: CGFloat = 1

    // MARK: Initialization

    init(touch: UITouch, sequenceNumber: Int, pointType: PointType) {
        self.sequenceNumber = sequenceNumber
        self.type = touch.type
        self.pointType = pointType

        let view = touch.view
        location = touch.preciseLocation(in: view)
        azimuthAngle = touch.azimuthAngle(in: view)
        estimatedProperties = touch.estimatedProperties
        estimatedPropertiesExpectingUpdates = touch.estimatedPropertiesExpectingUpdates
        altitudeAngle = touch.altitudeAngle
        timestamp = touch.timestamp

        if !estimatedPropertiesExpectingUpdates.isEmpty {
            self.pointType.formUnion(.NeedsUpdate)
        }

        estimationUpdateIndex = touch.estimationUpdateIndex
    }
}

// MARK: Estimated properties

extension LinePoint {
    func updateWithTouch(touch: UITouch) -> Bool {
        guard let estimationUpdateIndex = touch.estimationUpdateIndex, estimationUpdateIndex == estimationUpdateIndex else { return false }

        // Iterate through possible properties.
        for expectedProperty in PointType.touchUpdateProperties where estimatedPropertiesExpectingUpdates.contains(expectedProperty) {
            update(touchProperty: expectedProperty, touch: touch)

            if !touch.estimatedProperties.contains(expectedProperty) {
                // Flag that this point now has a 'final' value for this property.
                estimatedProperties.subtract(expectedProperty)
            }

            if !touch.estimatedPropertiesExpectingUpdates.contains(expectedProperty) {
                // Flag that this point is no longer expecting updates for this property.
                estimatedPropertiesExpectingUpdates.subtract(expectedProperty)

                if estimatedPropertiesExpectingUpdates.isEmpty {
                    // Flag that this point has been updated and no longer needs updates.
                    pointType.subtract(.NeedsUpdate)
                    pointType.formUnion(.Updated)
                }
            }
        }

        return true
    }

    func update(touchProperty: UITouchProperties, touch: UITouch) {
        switch touchProperty {
        case .azimuth:
            azimuthAngle = touch.azimuthAngle(in: touch.view)
        case .altitude:
            altitudeAngle = touch.altitudeAngle
        case .location:
            location = touch.preciseLocation(in: touch.view)
        default:
            break
        }
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
