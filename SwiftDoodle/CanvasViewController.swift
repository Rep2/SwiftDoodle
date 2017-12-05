import UIKit
import SnapKit

open class CanvasViewController: UIViewController {
    lazy var paletteViewModel: PaletteViewModel = {
        return PaletteViewModel(color: .black, width: 5, tool: .pencil, backgroundColor: self.view.backgroundColor ?? .white, scale: UIApplication.shared.keyWindow?.screen.scale ?? 2)
    }()

    lazy var canvasView: DrawView = {
        let view = DrawView(frame: .zero)

        view.backgroundColor = .white

        return view
    }()

    lazy var paletteView: PaletteView = {
        let view = PaletteView.viewFromNib

        view.eventHandler = self
        view.present(viewModel: self.paletteViewModel)

        return view
    }()

    override open func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        view.addSubview(canvasView)
        view.addSubview(paletteView)

        canvasView.snp.makeConstraints { view in
            view.edges.equalTo(self.view)
        }

        paletteView.snp.makeConstraints { view in
            view.height.equalTo(142)
            view.width.equalTo(498)
            view.bottom.equalTo(self.view)
            view.centerX.equalTo(self.view)
        }
    }
}

extension CanvasViewController: PaletteViewEventHandler {
    public func modelDidChange(viewModel: PaletteViewModel) {
        self.paletteViewModel = viewModel

        canvasView.set(paletteViewModel: paletteViewModel)
    }
}
