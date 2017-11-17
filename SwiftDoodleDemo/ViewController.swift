import UIKit
import SwiftDoodle

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view = DrawView(frame: view.frame)
        view.backgroundColor = .white
    }
}
