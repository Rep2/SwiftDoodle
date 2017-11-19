import UIKit

public class CanvasView: UIView {
    // MARK: Properties

    let isPredictionEnabled = UIDevice.current.userInterfaceIdiom == .pad

    var needsFullRedraw = true

    /// Array containing all line objects that need to be drawn in `drawRect(_:)`.
    var lines = [Line]()

    /// Array containing all line objects that have been completely drawn into the frozenContext.
    var finishedLines = [Line]()

    /**
     Holds a map of `UITouch` objects to `Line` objects whose touch has not ended yet.

     Use `NSMapTable` to handle association as `UITouch` doesn't conform to `NSCopying`. There is no value
     in accessing the properties of the touch used as a key in the map table. `UITouch` properties should
     be accessed in `NSResponder` callbacks and methods called from them.
     */
    let activeLines: NSMapTable<UITouch, Line> = NSMapTable.strongToStrongObjects()

    /**
     Holds a map of `UITouch` objects to `Line` objects whose touch has ended but still has points awaiting
     updates.

     Use `NSMapTable` to handle association as `UITouch` doesn't conform to `NSCopying`. There is no value
     in accessing the properties of the touch used as a key in the map table. `UITouch` properties should
     be accessed in `NSResponder` callbacks and methods called from them.
     */
    let pendingLines: NSMapTable<UITouch, Line> = NSMapTable.strongToStrongObjects()

    /// An optional `CGImage` containing the last representation of lines no longer receiving updates.
    var frozenImage: CGImage?

    /// A `CGContext` for drawing the last representation of lines no longer receiving updates into.
    lazy var frozenContext: CGContext = {
        let scale = self.window!.screen.scale
        var size = self.bounds.size

        size.width *= scale
        size.height *= scale

        let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!

        context.setLineCap(.round)

       let transform = CGAffineTransform(scaleX: scale, y: scale)
        context.concatenate(transform)

        return context
    }()

    // MARK: Drawing

    override public func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            if needsFullRedraw {
                setFrozenImageNeedsUpdate()
                frozenContext.clear(bounds)

                for array in [finishedLines, lines] {
                    for line in array {
                        line.drawCommitedPointsInContext(context: frozenContext)
                    }
                }

                needsFullRedraw = false
            }

            frozenImage = frozenImage ?? frozenContext.makeImage()

            if let frozenImage = frozenImage {
                context.draw(frozenImage, in: bounds)
            }

            lines.forEach { context.draw(points: $0.points) }
        }
    }

    func setFrozenImageNeedsUpdate() {
        frozenImage = nil
    }

    // MARK: Actions

    func clear() {
        activeLines.removeAllObjects()
        pendingLines.removeAllObjects()
        lines.removeAll()
        finishedLines.removeAll()
        needsFullRedraw = true
        setNeedsDisplay()
    }

    // MARK: Convenience

    func drawTouches(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var updateRect = CGRect.null

        touches.forEach { touch in
            // Retrieve a line from `activeLines`. If no line exists, create one.
            let line = activeLines.object(forKey: touch) ?? createLine(forTouch: touch)

            /*
             Remove prior predicted points and update the `updateRect` based on the removals. The touches
             used to create these points are predictions provided to offer additional data. They are stale
             by the time of the next event for this touch.
             */
            updateRect = line.removePoints(ofType: .Predicted).union(updateRect)

            /*
             Incorporate coalesced touch data. The data in the last touch in the returned array will match
             the data of the touch supplied to `coalescedTouchesForTouch(_:)`
             */
            let coalescedTouches = event?.coalescedTouches(for: touch) ?? []
            updateRect = addPointsOfType(type: .Coalesced, forTouches: coalescedTouches, toLine: line, currentUpdateRect: updateRect)

            /*
             Incorporate predicted touch data. This sample draws predicted touches differently; however,
             you may want to use them as inputs to smoothing algorithms rather than directly drawing them.
             Points derived from predicted touches should be removed from the line at the next event for
             this touch.
             */
            if isPredictionEnabled {
                let predictedTouches = event?.predictedTouches(for: touch) ?? []
                updateRect = addPointsOfType(type: .Predicted, forTouches: predictedTouches, toLine: line, currentUpdateRect: updateRect)
            }
        }

        setNeedsDisplay(updateRect)
    }

    func createLine(forTouch touch: UITouch) -> Line {
        let newLine = Line()

        activeLines.setObject(newLine, forKey: touch)
        lines.append(newLine)

        return newLine
    }

    func addPointsOfType(type: LinePoint.PointType, forTouches touches: [UITouch], toLine line: Line, currentUpdateRect updateRect: CGRect) -> CGRect {
        let updateRect = line.addPointsOfType(type: type, forTouches: touches, currentUpdateRect: updateRect)

        commitLine(line: line)

        return updateRect
    }

    func endTouches(touches: Set<UITouch>, cancel: Bool) {
        var updateRect = CGRect.null

        for touch in touches {
            // Skip over touches that do not correspond to an active line.
            guard let line = activeLines.object(forKey: touch) else { continue }

            // If this is a touch cancellation, cancel the associated line.
            if cancel {
                updateRect = updateRect.union(line.cancel())
            }

            // If the line is complete (no points needing updates) or updating isn't enabled, move the line to the `frozenImage`.
            if line.isComplete {
                finishLine(line: line)
            } else {
                pendingLines.setObject(line, forKey: touch)
            }

            // This touch is ending, remove the line corresponding to it from `activeLines`.
            activeLines.removeObject(forKey: touch)
        }

        setNeedsDisplay(updateRect)
    }

    func commitLine(line: Line) {
        line.drawFixedPointsInContext(context: frozenContext)
        setFrozenImageNeedsUpdate()
    }

    func finishLine(line: Line) {
        // Have the line draw any remaining segments into the `frozenContext`. All should be fixed now.
        line.drawFixedPointsInContext(context: frozenContext, commitAll: true)
        setFrozenImageNeedsUpdate()

        // Cease tracking this line now that it is finished.
        lines.remove(at: lines.index(of: line)!)

        // Store into finished lines to allow for a full redraw on option changes.
        finishedLines.append(line)
    }
}

// MARK: Estimated properties

extension CanvasView {
    func updateEstimatedPropertiesForTouches(touches: Set<UITouch>) {
        for touch in touches {
            var isPending = false

            // Look to retrieve a line from `activeLines`. If no line exists, look it up in `pendingLines`.
            let possibleLine: Line? = activeLines.object(forKey: touch) ?? {
                let pendingLine = pendingLines.object(forKey: touch)
                isPending = pendingLine != nil
                return pendingLine
                }()

            // If no line is related to the touch, return as there is no additional work to do.
            guard let line = possibleLine else { return }

            switch line.updateWithTouch(touch: touch) {
            case (true, let updateRect):
                setNeedsDisplay(updateRect)
            default:
                ()
            }

            // If this update updated the last point requiring an update, move the line to the `frozenImage`.
            if isPending && line.isComplete {
                finishLine(line: line)
                pendingLines.removeObject(forKey: touch)
            }
                // Otherwise, have the line add any points no longer requiring updates to the `frozenImage`.
            else {
                commitLine(line: line)
            }
        }
    }
}
