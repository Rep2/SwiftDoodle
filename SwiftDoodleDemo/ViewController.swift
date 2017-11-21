import UIKit
import SwiftDoodle
import SnapKit

class ViewController: UIViewController {
    let palette = Palette(color: .black, width: 5)

    lazy var canvasView: DrawView = {
        let view = DrawView(scale: ApplicationManager.shared.scale, palette: palette)

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
