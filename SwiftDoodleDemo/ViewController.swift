import UIKit
import SwiftDoodle
import SnapKit

class ViewController: UIViewController {
    let palette = PaletteModel(color: .black, width: 5, tool: .pencil)

    lazy var canvasView: DrawView = {
        let view = DrawView(scale: ApplicationManager.shared.scale, palette: palette)

        view.backgroundColor = .white

        return view
    }()

    lazy var paletteView: PaletteView = {
        let view = PaletteView.viewFromNib

        view.present(model: self.palette)

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        title = "Demo"

        view.addSubview(canvasView)
        view.addSubview(paletteView)

        canvasView.snp.makeConstraints { view in
            view.edges.equalTo(self.view)
        }

        paletteView.snp.makeConstraints { view in
            view.height.equalTo(126)
            view.width.equalTo(440)
            view.bottom.equalTo(self.view)
            view.centerX.equalTo(self.view)
        }
    }
}
