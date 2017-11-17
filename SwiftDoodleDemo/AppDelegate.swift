import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        if let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let logPath = documentsDirectory.appendingFormat("/SwiftDoodleDemo.txt")

            freopen(logPath.cString(using: String.Encoding.ascii)!, "a+", stderr)
        }

        return true
    }
}
