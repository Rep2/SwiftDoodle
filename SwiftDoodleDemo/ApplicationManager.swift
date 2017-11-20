import UIKit

class ApplicationManager {
    static var shared: ApplicationManager!

    lazy var rootNavigationController: UINavigationController = {
        let rootViewController = ViewController()

        let navigationController = UINavigationController(rootViewController: rootViewController)

        navigationController.navigationBar.isTranslucent = false

        return navigationController
    }()

    let scale: CGFloat

    init(scale: CGFloat) {
        self.scale = scale
    }
}
