import UIKit

class ApplicationManager {
    static let shared = ApplicationManager()

    lazy var rootNavigationController: UIViewController = {
        return ViewController()
    }()
}
