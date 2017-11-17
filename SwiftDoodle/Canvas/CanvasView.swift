import UIKit

public class CanvasView: UIView {
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches began: \(touches)")
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches moved: \(touches)")
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches ended: \(touches)")
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches cancelled: \(touches)")
    }
}
