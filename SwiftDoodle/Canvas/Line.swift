import UIKit

class Line: NSObject {
    // MARK: Properties

    // The live line
    var points = [LinePoint]()

    // Use the estimation index of the touch to track points awaiting updates.
    var pointsWaitingForUpdatesByEstimationIndex = [NSNumber: LinePoint]()

    // Points already drawn into 'frozen' representation of this line.
    var committedPoints = [LinePoint]()

    var isComplete: Bool {
        return pointsWaitingForUpdatesByEstimationIndex.isEmpty
    }

    // MARK: Interface

    func newPoint(ofType pointType: LinePoint.PointType, forTouch touch: UITouch) -> CGRect {
        let point = addPoint(ofType: pointType, forTouch: touch)

        return points
            .get(atIndex: points.count - 2)
            .flatMap { point.drawRect(withPreviousPoint: $0) } ??
            point.drawRect
    }

    func addPoint(ofType pointType: LinePoint.PointType, forTouch touch: UITouch) -> LinePoint {
        let point = LinePoint(touch: touch, sequenceNumber: points.count, pointType: pointType)

        points.append(point)

        // If the point is estimated, add it to points waiting for update
        if let estimationIndex = point.estimationUpdateIndex, !point.estimatedPropertiesExpectingUpdates.isEmpty {
            pointsWaitingForUpdatesByEstimationIndex[estimationIndex] = point
        }

        return point
    }

    func removePoints(ofType type: LinePoint.PointType) -> CGRect {
        var updateRect = CGRect.null
        var priorPoint: LinePoint?

        points = points.filter { point in
            let keepPoint = !point.pointType.contains(type)

            if !keepPoint {
                var rect = point.drawRect

                if let priorPoint = priorPoint {
                    rect = rect.union(priorPoint.drawRect)
                }

                updateRect = updateRect.union(rect)
            }

            priorPoint = point

            return keepPoint
        }

        return updateRect
    }

    func cancel() -> CGRect {
        // Process each point in the line and accumulate the `CGRect` containing all the points.
        let updateRect = points.reduce(CGRect.null) { accumulated, point in
            // Update the type set to include `.Cancelled`.
            point.pointType.formUnion(.Cancelled)

            /*
             Union the `CGRect` for this point with accumulated `CGRect` and return it. The result is
             supplied to the next invocation of the closure.
             */
            return accumulated.union(point.drawRect)
        }

        return updateRect
    }

    // MARK: Drawing

    func drawFixedPointsInContext(context: CGContext, commitAll: Bool = false) {
        let allPoints = points
        var committing = [LinePoint]()

        if commitAll {
            committing = allPoints
            points.removeAll()
        } else {
            for (index, point) in allPoints.enumerated() {
                // Only points whose type does not include `.NeedsUpdate` or `.Predicted` and are not last or prior to last point can be committed.
                guard point.pointType.intersection([.NeedsUpdate, .Predicted]).isEmpty && index < allPoints.count - 2 else {
                    committing.append(points.first!)
                    break
                }

                guard index > 0 else { continue }

                let removed = points.remove(at: index)
                committing.append(removed)
            }
        }

        // If only one point could be committed, no further action is required. Otherwise, draw the `committedLine`.
        guard committing.count > 1 else { return }

        context.draw(points: points)

        if !committedPoints.isEmpty {
            // Remove what was the last point committed point; it is also the first point being committed now.
            committedPoints.removeLast()
        }

        // Store the points being committed for redrawing later in a different style if needed.
        committedPoints.append(contentsOf: committing)
    }

    func drawCommitedPointsInContext(context: CGContext) {
        context.draw(points: committedPoints)
    }
}

// MARK: Estimated properties

extension Line {
    func updateWithTouch(touch: UITouch) -> (Bool, CGRect) {
        if let estimationUpdateIndex = touch.estimationUpdateIndex,
            let point = pointsWaitingForUpdatesByEstimationIndex[estimationUpdateIndex] {

            var rect = updateRectForExistingPoint(point: point)
            let didUpdate = point.updateWithTouch(touch: touch)

            if didUpdate {
                rect = rect.union(updateRectForExistingPoint(point: point))
            }

            if point.estimatedPropertiesExpectingUpdates == [] {
                pointsWaitingForUpdatesByEstimationIndex.removeValue(forKey: estimationUpdateIndex)
            }

            return (didUpdate, rect)
        }

        return (false, CGRect.null)
    }

    func updateRectForExistingPoint(point: LinePoint) -> CGRect {
        var rect = point.drawRect

        let arrayIndex = point.sequenceNumber

        if arrayIndex > 0 {
            rect = rect.union(point.drawRect(withPreviousPoint: points[arrayIndex - 1]))
        }

        if arrayIndex + 1 < points.count {
            rect = rect.union(point.drawRect(withPreviousPoint: points[arrayIndex + 1]))
        }

        return rect
    }
}
