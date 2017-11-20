import UIKit

extension CanvasView {
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawTouches(touches: touches, withEvent: event)
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawTouches(touches: touches, withEvent: event)
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawTouches(touches: touches, withEvent: event)
        endTouches(touches: touches)
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouches(touches: touches)
    }
}
