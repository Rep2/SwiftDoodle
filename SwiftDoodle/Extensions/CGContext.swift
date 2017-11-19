import UIKit

extension CGContext {
    func draw(points: [LinePoint]) {
        var points = points

        if let firstPoint = try? points.remove(safeAtIndex: 0) {
            setStrokeColor(firstPoint.drawColor.cgColor)
            setLineWidth(1)

            beginPath()

            move(to: CGPoint(x: firstPoint.location.x, y: firstPoint.location.y))

            points
                .forEach { addLine(to: CGPoint(x: $0.location.x, y: $0.location.y)) }

            strokePath()
        }
    }
}
