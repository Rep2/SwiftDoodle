import UIKit

public class CanvasView: UIView {

    // MARK: Properties

    let activeLines: NSMapTable<UITouch, Line> = NSMapTable.strongToStrongObjects()

    /// A `CGContext` for drawing the last representation of lines no longer receiving updates into.
    var frozenContext: CGContext!

    let scale: CGFloat

    var originalBounds: CGRect!

    override public var bounds: CGRect {
        didSet {
            if originalBounds == nil {
                originalBounds = bounds
                frozenContext = CGContext.context(withSize: bounds.size, scale: scale)
            }

            originalBounds.origin.x = max(0, (bounds.width - originalBounds.width) / 2)
            originalBounds.origin.y = max(0, (bounds.height - originalBounds.height) / 2)

            setNeedsDisplay()
        }
    }

    public init(scale: CGFloat) {
        self.scale = scale

        super.init(frame: .zero)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Drawing

    override public func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineCap(.round)

            frozenContext
                .makeImage()
                .flatMap { context.draw($0, in: originalBounds) }
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
        touches.forEach(activeLines.removeObject)
    }

    // MARK: Actions

    /// Removes all drawing data
    public func clear() {
        activeLines.removeAllObjects()
        frozenContext.clear(bounds)
        setNeedsDisplay()
    }

    // MARK: Convenience

    private func updateLine(associatedWith touch: UITouch, event: UIEvent?) -> CGRect {
        let lineAssociatedWithTouch = line(for: touch)

        let coalescedTouches = event?.coalescedTouches(for: touch) ?? []
        lineAssociatedWithTouch.addPoints(for: coalescedTouches)

        let pointsToBeDrawn = lineAssociatedWithTouch.pointsToBeDrawn

        frozenContext.draw(points: pointsToBeDrawn)

        return Point.updateRect(for: pointsToBeDrawn, magnitude: 10)
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
