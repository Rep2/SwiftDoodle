import UIKit

extension CGContext {
    func draw(points: [LinePoint]) {
        _ = points
            .reduce(nil) { (priorPoint, point) -> LinePoint? in
                guard let priorPoint = priorPoint else { return point }

                setStrokeColor(point.drawColor.cgColor)

                beginPath()

                move(to: CGPoint(x: point.location.x, y: point.location.y))
                addLine(to: CGPoint(x: priorPoint.location.x, y: priorPoint.location.y))

                setLineWidth(point.drawWidth)

                strokePath()

                return point
            }
    }
}
