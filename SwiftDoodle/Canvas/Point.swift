struct Point {
    var location: CGPoint

    init(touch: UITouch) {
        location = touch.preciseLocation(in: touch.view)
    }

    static func updateRect(for points: [Point], magnitude: CGFloat) -> CGRect {
        var updateRect = CGRect.zero

        _ = points.reduce(nil) { (previousPoint: Point?, currentPoint: Point) in
            if let previousPoint = previousPoint {
                updateRect = currentPoint
                    .updateRect(with: previousPoint, magnitude: magnitude)
                    .union(updateRect)
            }

            return currentPoint
        }

        return updateRect
    }

    private var centerRect: CGRect {
        return CGRect(origin: location, size: .zero)
    }

    private func updateRect(with previousPoint: Point, magnitude: CGFloat) -> CGRect {
        return centerRect
            .union(previousPoint.centerRect)
            .insetBy(dx: -magnitude, dy: -magnitude)
    }
}
