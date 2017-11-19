import UIKit
import SwiftDoodle

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view = CanvasView(frame: view.frame)
        view.backgroundColor = .white
    }
}
