import UIKit
import SwiftUI

@objc(AppDelegate)
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        
        window?.rootViewController = hostingController
        window?.makeKeyAndVisible()
        
        return true
    }
}
