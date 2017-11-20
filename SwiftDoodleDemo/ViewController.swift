import UIKit
import SwiftDoodle

class ViewController: UIViewController {
    lazy var canvasView: CanvasView = {
        let view = CanvasView(frame: self.view.frame)

        view.backgroundColor = .white

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view = canvasView
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        canvasView.updateContextSize(to: size)
    }
}
