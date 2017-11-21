import UIKit

class Line {
    var points = [Point]()

    var pointsToBeDrawn: [Point] {
        guard points.count > 1 else {
            return []
        }

        let allPoints = points

        points = [points.last!]

        return allPoints
    }

    func addPoints(for touches: [UITouch]) {
        touches.forEach {
            points.append(Point(touch: $0))
        }
    }
}
