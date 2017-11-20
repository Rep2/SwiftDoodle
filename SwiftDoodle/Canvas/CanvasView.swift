import UIKit

public class CanvasView: UIView {

    // MARK: Properties

    var needsFullRedraw = true

    var finishedLines = [Line]()

    let activeLines: NSMapTable<UITouch, Line> = NSMapTable.strongToStrongObjects()

    /// A `CGContext` for drawing the last representation of lines no longer receiving updates into.
    var frozenContext: CGContext

    public init(frame: CGRect, scale: CGFloat) {
        frozenContext = CGContext.context(withSize: frame.size, scale: scale)

        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Drawing

    override public func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineCap(.round)

            if needsFullRedraw {
                frozenContext.clear(bounds)

                finishedLines
                    .forEach { frozenContext.draw(points: $0.committedPoints) }

                needsFullRedraw = false
            }

            frozenContext
                .makeImage()
                .flatMap { context.draw($0, in: bounds) }
        }
    }

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

    // MARK: Actions

    /// Removes all drawing data
    public func clear() {
        activeLines.removeAllObjects()
        finishedLines.removeAll()
        needsFullRedraw = true
        setNeedsDisplay()
    }

    /// Updates the views size. Must be called on screen rotation.
    public func screenSizeDidChange(size: CGSize, scale: CGFloat) {
        frozenContext = CGContext.context(withSize: size, scale: scale)
        needsFullRedraw = true
    }

    // MARK: Convenience

    private func updateLine(associatedWith touch: UITouch, event: UIEvent?) -> CGRect {
        let lineAssociatedWithTouch = line(for: touch)

        let coalescedTouches = event?.coalescedTouches(for: touch) ?? []
        let updateRect = lineAssociatedWithTouch.addPointsOfType(type: .Coalesced, forTouches: coalescedTouches)

        frozenContext.draw(points: lineAssociatedWithTouch.pointsToBeDrawn)

        return updateRect
    }

    /// Retrieve a line from `activeLines`. If no line exists, create one.
    private func line(for touch: UITouch) -> Line {
        return activeLines.object(forKey: touch) ?? createLine(forTouch: touch)
    }

    /// Create a line associated with touch
    private func createLine(forTouch touch: UITouch) -> Line {
        let newLine = Line()

        activeLines.setObject(newLine, forKey: touch)

        return newLine
    }
}
