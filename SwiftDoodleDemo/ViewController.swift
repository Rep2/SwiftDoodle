import UIKit
import SwiftDoodle

class ViewController: UIViewController {
    lazy var canvasView: CanvasView = {
        let view = CanvasView(frame: self.view.frame)

        view.backgroundColor = .white

        return view
    }()

    lazy var paletteView: PaletteView = {
        let view = PaletteView(containerSize: self.view.bounds.size, location: .right)

        view.backgroundColor = .black

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view = canvasView
//        view.addSubview(paletteView)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        canvasView.updateContextSize(to: size)
    }
}
