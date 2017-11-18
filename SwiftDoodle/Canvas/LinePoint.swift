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

        static let touchUpdateProperties: [UITouchProperties] = [.altitude, .azimuth, .force, .location]
    }

    // MARK: Properties

    var sequenceNumber: Int
    let timestamp: TimeInterval
    var force: CGFloat
    var location: CGPoint
    var estimatedPropertiesExpectingUpdates: UITouchProperties
    var estimatedProperties: UITouchProperties
    let type: UITouchType
    var altitudeAngle: CGFloat
    var azimuthAngle: CGFloat
    let estimationUpdateIndex: NSNumber?

    var pointType: PointType

    var magnitude: CGFloat {
        return max(force, 0.025)
    }

    var color: UIColor {
        var color = UIColor.black

        if pointType.contains(.Cancelled) {
            color = .clear
        } else if pointType.contains(.Predicted) {
            color = color.withAlphaComponent(0.5)
        }

        return color
    }

    // MARK: Initialization

    init(touch: UITouch, sequenceNumber: Int, pointType: PointType) {
        self.sequenceNumber = sequenceNumber
        self.type = touch.type
        self.pointType = pointType

        timestamp = touch.timestamp
        let view = touch.view
        location = touch.preciseLocation(in: view)
        azimuthAngle = touch.azimuthAngle(in: view)
        estimatedProperties = touch.estimatedProperties
        estimatedPropertiesExpectingUpdates = touch.estimatedPropertiesExpectingUpdates
        altitudeAngle = touch.altitudeAngle
        force = (type == .stylus || touch.force > 0) ? touch.force : 1.0

        if !estimatedPropertiesExpectingUpdates.isEmpty {
            self.pointType.formUnion(.NeedsUpdate)
        }

        estimationUpdateIndex = touch.estimationUpdateIndex
    }

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
        case .force:
            force = touch.force
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
