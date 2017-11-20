import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        ApplicationManager.shared = ApplicationManager(scale: window?.screen.scale ?? 2)

        window?.rootViewController = ApplicationManager.shared.rootNavigationController
        window?.makeKeyAndVisible()

        return true
    }
}
