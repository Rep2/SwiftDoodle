import UIKit

class Line: NSObject {
    // The live line
    var points = [LinePoint]()

    // Points already drawn into 'frozen' representation of this line.
    var committedPoints = [LinePoint]()

    // MARK: Interface

    var pointsToBeDrawn: [LinePoint] {
        guard points.count > 1 else {
            return []
        }

        let allPoints = points
        storeCommitedPoints(allPoints)

        points = [points.last!]

        return allPoints
    }

    func addPointsOfType(type: LinePoint.PointType, forTouches touches: [UITouch]) -> CGRect {
        var updateRect = CGRect.zero

        touches
            .forEach { touch in
                updateRect = addPoint(ofType: type, forTouch: touch)
                    .union(updateRect)
            }

        return updateRect
    }

    // MARK: Convenience

    private func storeCommitedPoints(_ points: [LinePoint]) {
        if !committedPoints.isEmpty {
            // Remove what was the last point committed point; it is also the first point being committed now.
            committedPoints.removeLast()
        }

        committedPoints.append(contentsOf: points)
    }

    private func addPoint(ofType pointType: LinePoint.PointType, forTouch touch: UITouch) -> CGRect {
        let point = LinePoint(touch: touch, pointType: pointType)

        points.append(point)

        return points
            .get(atIndex: points.count - 2)
            .flatMap { point.drawRect(withPreviousPoint: $0) } ??
            point.drawRect
    }
}
