import UIKit

class Line: NSObject {
    // MARK: Properties

    // The live line
    var points = [LinePoint]()

    // Points already drawn into 'frozen' representation of this line.
    var committedPoints = [LinePoint]()

    // MARK: Interface

    func addPoint(ofType pointType: LinePoint.PointType, forTouch touch: UITouch) -> CGRect {
        let point = createPoint(ofType: pointType, forTouch: touch)

        return points
            .get(atIndex: points.count - 2)
            .flatMap { point.drawRect(withPreviousPoint: $0) } ??
            point.drawRect
    }

    private func createPoint(ofType pointType: LinePoint.PointType, forTouch touch: UITouch) -> LinePoint {
        let point = LinePoint(touch: touch, sequenceNumber: points.count, pointType: pointType)

        points.append(point)

        return point
    }

    // MARK: Drawing

    var pointsToBeDrawn: [LinePoint] {
        guard points.count > 1 else {
            return []
        }

        let allPoints = points
        storeCommitedPoints(allPoints)

        points = [points.last!]

        return allPoints
    }

    func storeCommitedPoints(_ points: [LinePoint]) {
        if !committedPoints.isEmpty {
            // Remove what was the last point committed point; it is also the first point being committed now.
            committedPoints.removeLast()
        }

        committedPoints.append(contentsOf: points)
    }

    func drawCommitedPointsInContext(context: CGContext) {
        draw(points: committedPoints, inContext: context)
    }

    func draw(points: [LinePoint], inContext context: CGContext) {
        context.draw(points: points)
    }

    func addPointsOfType(type: LinePoint.PointType, forTouches touches: [UITouch]) -> CGRect {
        var updateRect = CGRect.zero
        var type = type

        for (index, touch) in touches.enumerated() {
            // The visualization displays non-`.Stylus` touches differently.
            if touch.type != .stylus {
                type.formUnion(.Finger)
            }

            // Touches with estimated properties require updates; add this information to the `PointType`.
            if !touch.estimatedProperties.isEmpty {
                type.formUnion(.NeedsUpdate)
            }

            // The last touch in a set of `.Coalesced` touches is the originating touch. Track it differently.
            if type.contains(.Coalesced) && index == touches.count - 1 {
                type.subtract(.Coalesced)
                type.formUnion(.Standard)
            }

            updateRect = addPoint(ofType: type, forTouch: touch)
                .union(updateRect)
        }

        return updateRect
    }
}
