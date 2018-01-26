import UIKit

/*
 UIView that supports drawing.

 Works with both AutoLayout and frames.

 On resize updates drawing context,
 but discards all changes outside of the new bounds.
 */
open class DrawView: UIView {

    /// Lines currently being drawn
    let activeLines: NSMapTable<UITouch, Line> = NSMapTable.strongToStrongObjects()

    var finishedLines = [Line]()

    /// Context used to draw
    lazy var drawingContext: CGContext = {
        return CGContext.context(withSize: bounds.size, scale: paletteViewModel.scale)
    }()

    /// Palette used to customize drawing
    var paletteViewModel = PaletteViewModel.basic

    /*
     Resizes the drawing context on view resize.

     Discards any data outside out of the new bounds.
     */
    override open var bounds: CGRect {
        didSet {
            // Currently displayed image
            let oldImage = drawingContext.makeImage()

            // Creates context with new view size
            drawingContext = CGContext.context(withSize: bounds.size, scale: paletteViewModel.scale)

            // If old image exists, draw it on a new context
            if let oldImage = oldImage {
                drawingContext.draw(oldImage, in: oldValue)
            }

            setNeedsDisplay()
        }
    }

    // MARK: Drawing

    override open func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineCap(.round)

            // Draws new image in the current context
            if let newImage = drawingContext.makeImage() {
                context.draw(newImage, in: bounds)
            }
        }
    }

    fileprivate func drawTouches(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard isDrawingEnabled else { return }

        var linesToBeDrawn = [[Point]]()

        touches.forEach { touch in
            linesToBeDrawn.append(self.pointsToBeDrawn(associatedWith: touch, event: event))
        }

        let updateRect = linesToBeDrawn
            .reduce(CGRect.zero) { updateRect, points in
                self.drawingContext.draw(points: points, palette: paletteViewModel)

                return Point.updateRect(for: points, lineWidth: CGFloat(paletteViewModel.width)).union(updateRect)
            }

        setNeedsDisplay(updateRect)
    }

    fileprivate func endTouches(touches: Set<UITouch>) {
        touches
            .forEach {
                if let line = activeLines.object(forKey: $0) {
                    finishedLines.append(line)
                }

                activeLines.removeObject(forKey: $0)
            }
    }

    // MARK: Actions

    /// Removes all drawing data
    public func clear() {
        activeLines.removeAllObjects()
        drawingContext.clear(bounds)
        setNeedsDisplay()
    }

    public func set(paletteViewModel: PaletteViewModel) {
        backgroundColor = paletteViewModel.backgroundColor

        self.paletteViewModel = paletteViewModel
    }

    public func set(image: CGImage?) {
        drawingContext = CGContext.context(withSize: bounds.size, scale: paletteViewModel.scale)

        if let image = image {
            drawingContext.draw(image, in: bounds)
        }

        setNeedsDisplay()
    }

    public var isDrawingEnabled = true

    public var currentImage: UIImage? {
        guard let cgImage = drawingContext.makeImage() else { return nil }

        return UIImage(cgImage: cgImage, scale: 1, orientation: .downMirrored)
    }

    // MARK: Convenience

    private func pointsToBeDrawn(associatedWith touch: UITouch, event: UIEvent?) -> [Point] {
        let lineAssociatedWithTouch = line(for: touch)

        let coalescedTouches = event?.coalescedTouches(for: touch) ?? []
        lineAssociatedWithTouch.addPoints(for: coalescedTouches)

        return lineAssociatedWithTouch.calculatePointsToBeDrawn()
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

extension DrawView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawTouches(touches: touches, withEvent: event)
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawTouches(touches: touches, withEvent: event)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawTouches(touches: touches, withEvent: event)
        endTouches(touches: touches)
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouches(touches: touches)
    }
}
