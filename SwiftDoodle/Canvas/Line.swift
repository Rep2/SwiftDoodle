import UIKit

class Line {
    var points = [Point]()

    let paletteViewModel: PaletteViewModel

    init(paletteViewModel: PaletteViewModel) {
        self.paletteViewModel = paletteViewModel
    }

    func addPoints(for touches: [UITouch]) {
        touches.forEach {
            points.append(Point(touch: $0))
        }
    }
}
