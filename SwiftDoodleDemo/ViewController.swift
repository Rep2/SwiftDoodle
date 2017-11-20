import UIKit
import SwiftDoodle

class ViewController: UIViewController {
    lazy var canvasView: CanvasView = {
        let view = CanvasView(frame: CGRect(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height - 64), scale: ApplicationManager.shared.scale)

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
        view.addSubview(paletteView)

        title = "Demo"
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        canvasView.screenSizeDidChange(size: CGSize(width: size.width, height: size.height - 64), scale: ApplicationManager.shared.scale)
    }
}
