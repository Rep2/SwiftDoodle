import UIKit

extension CGContext {
    func draw(points: [LinePoint]) {
        _ = points
            .reduce(nil) { (priorPoint, point) -> LinePoint? in
                guard let priorPoint = priorPoint else { return point }

                setStrokeColor(point.color.cgColor)

                beginPath()

                move(to: CGPoint(x: point.preciseLocation.x, y: point.preciseLocation.y))
                addLine(to: CGPoint(x: priorPoint.preciseLocation.x, y: priorPoint.preciseLocation.y))

                setLineWidth(point.magnitude)

                strokePath()

                return point
            }
    }
}
