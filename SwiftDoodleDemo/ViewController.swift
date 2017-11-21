import UIKit
import SwiftDoodle
import SnapKit

class ViewController: UIViewController {
    lazy var canvasView: CanvasView = {
        let view = CanvasView(scale: ApplicationManager.shared.scale)

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

        setupView()
    }

    func setupView() {
        title = "Demo"

        view.addSubview(canvasView)

        canvasView.snp.makeConstraints { view in
            view.edges.equalTo(self.view)
        }
    }
}
