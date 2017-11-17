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

    // MARK: Interface

    func addPointOfType(pointType: LinePoint.PointType, forTouch touch: UITouch) -> CGRect {
        let previousPoint = points.last
        let previousSequenceNumber = previousPoint?.sequenceNumber ?? -1
        let point = LinePoint(touch: touch, sequenceNumber: previousSequenceNumber + 1, pointType: pointType)

        if let estimationIndex = point.estimationUpdateIndex {
            if !point.estimatedPropertiesExpectingUpdates.isEmpty {
                pointsWaitingForUpdatesByEstimationIndex[estimationIndex] = point
            }
        }

        points.append(point)

        let updateRect = updateRectForLinePoint(point: point, previousPoint: previousPoint)

        return updateRect
    }

    func removePointsWithType(type: LinePoint.PointType) -> CGRect {
        var updateRect = CGRect.null
        var priorPoint: LinePoint?

        points = points.filter { point in
            let keepPoint = !point.pointType.contains(type)

            if !keepPoint {
                var rect = self.updateRectForLinePoint(point: point)

                if let priorPoint = priorPoint {
                    rect = rect.union(updateRectForLinePoint(point: priorPoint))
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
            return accumulated.union(updateRectForLinePoint(point: point))
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

                // First time to this point should be index 1 if there is a line segment that can be committed.
                let removed = points.removeFirst()
                committing.append(removed)
            }
        }
        // If only one point could be committed, no further action is required. Otherwise, draw the `committedLine`.
        guard committing.count > 1 else { return }

        let committedLine = Line()
        committedLine.points = committing
        context.draw(points: points)

        if !committedPoints.isEmpty {
            // Remove what was the last point committed point; it is also the first point being committed now.
            committedPoints.removeLast()
        }

        // Store the points being committed for redrawing later in a different style if needed.
        committedPoints.append(contentsOf: committing)
    }

    func drawCommitedPointsInContext(context: CGContext) {
        let committedLine = Line()
        committedLine.points = committedPoints
        context.draw(points: points)
    }

    // MARK: Convenience

    func updateRectForLinePoint(point: LinePoint) -> CGRect {
        var rect = CGRect(origin: point.location, size: CGSize.zero)

        // The negative magnitude ensures an outset rectangle.
        let magnitude = -3 * point.magnitude - 2
        rect = rect.insetBy(dx: magnitude, dy: magnitude)

        return rect
    }

    func updateRectForLinePoint(point: LinePoint, previousPoint optionalPreviousPoint: LinePoint? = nil) -> CGRect {
        var rect = CGRect(origin: point.location, size: CGSize.zero)

        var pointMagnitude = point.magnitude

        if let previousPoint = optionalPreviousPoint {
            pointMagnitude = max(pointMagnitude, previousPoint.magnitude)
            rect = rect.union( CGRect(origin: previousPoint.location, size: CGSize.zero))
        }

        // The negative magnitude ensures an outset rectangle.
        let magnitude = -3.0 * pointMagnitude - 2.0
        rect = rect.insetBy(dx: magnitude, dy: magnitude)

        return rect
    }

    func updateRectForExistingPoint(point: LinePoint) -> CGRect {
        var rect = updateRectForLinePoint(point: point)

        let arrayIndex = point.sequenceNumber - points.first!.sequenceNumber

        if arrayIndex > 0 {
            rect = rect.union(updateRectForLinePoint(point: point, previousPoint: points[arrayIndex - 1]))
        }

        if arrayIndex + 1 < points.count {
            rect = rect.union(updateRectForLinePoint(point: point, previousPoint: points[arrayIndex + 1]))
        }

        return rect
    }

}
