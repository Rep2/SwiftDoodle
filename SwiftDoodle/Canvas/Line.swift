import UIKit

class Line {
    var points = [Point]()
    var drawnPoints = [Point]()

    func calculatePointsToBeDrawn() -> [Point] {
        guard points.count > 1 else {
            return []
        }

        let allPoints = points

        points = [points.last!]

        appendDrawnPoints(allPoints)

        return allPoints
    }

    func addPoints(for touches: [UITouch]) {
        touches.forEach {
            points.append(Point(touch: $0))
        }
    }

    func appendDrawnPoints(_ points: [Point]) {
        if !drawnPoints.isEmpty {
            drawnPoints.removeLast()
        }

        drawnPoints.append(contentsOf: points)
    }
}
