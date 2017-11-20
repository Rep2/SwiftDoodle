import UIKit

public class CanvasView: UIView {

    // MARK: Properties

    var needsFullRedraw = true

    /// Array containing all line objects that have been completely drawn into the frozenContext.
    var finishedLines = [Line]()

    /**
     Holds a map of `UITouch` objects to `Line` objects whose touch has not ended yet.

     Use `NSMapTable` to handle association as `UITouch` doesn't conform to `NSCopying`. There is no value
     in accessing the properties of the touch used as a key in the map table. `UITouch` properties should
     be accessed in `NSResponder` callbacks and methods called from them.
     */
    let activeLines: NSMapTable<UITouch, Line> = NSMapTable.strongToStrongObjects()

    /// A `CGContext` for drawing the last representation of lines no longer receiving updates into.
    lazy var frozenContext: CGContext = {
        return CGContext.context(withSize: self.bounds.size, scale: self.window!.screen.scale)
    }()

    // MARK: Drawing

    override public func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineCap(.round)

            if needsFullRedraw {
                frozenContext.clear(bounds)

                finishedLines
                    .forEach { $0.drawCommitedPointsInContext(context: frozenContext) }

                needsFullRedraw = false
            }

            frozenContext.drawImage(in: bounds)

        }
    }

    // MARK: Actions

    /// Removes all drawing data
    public func clear() {
        activeLines.removeAllObjects()
        finishedLines.removeAll()
        needsFullRedraw = true
        setNeedsDisplay()
    }

    /// Updates the views size. Must be called on screen rotation.
    public func updateContextSize(to size: CGSize) {
        frozenContext = CGContext.context(withSize: size, scale: window!.screen.scale)
        needsFullRedraw = true
    }

    // MARK: Convenience

    func drawTouches(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var updateRect = CGRect.null

        touches.forEach { touch in
            updateRect = self.updateLine(associatedWith: touch, event: event).union(updateRect)
        }

        setNeedsDisplay(updateRect)
    }

    func endTouches(touches: Set<UITouch>) {
        touches
            .forEach { touch in
                if let line = activeLines.object(forKey: touch) {
                    activeLines.removeObject(forKey: touch)
                    finishedLines.append(line)
                }
            }
    }

    func updateLine(associatedWith touch: UITouch, event: UIEvent?) -> CGRect {
        let lineAssociatedWithTouch = line(for: touch)

        let coalescedTouches = event?.coalescedTouches(for: touch) ?? []
        let updateRect = lineAssociatedWithTouch.addPointsOfType(type: .Coalesced, forTouches: coalescedTouches)

        frozenContext.draw(points: lineAssociatedWithTouch.pointsToBeDrawn)

        return updateRect
    }

    /// Retrieve a line from `activeLines`. If no line exists, create one.
    func line(for touch: UITouch) -> Line {
        return activeLines.object(forKey: touch) ?? createLine(forTouch: touch)
    }

    /// Create a line associated with touch
    func createLine(forTouch touch: UITouch) -> Line {
        let newLine = Line()

        activeLines.setObject(newLine, forKey: touch)

        return newLine
    }
}
