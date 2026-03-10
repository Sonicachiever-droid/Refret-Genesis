import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("🚀 App did finish launching")
        window = UIWindow(frame: UIScreen.main.bounds)
        print("🪟 Window created")
        
        let viewController = UIViewController()
        viewController.view.backgroundColor = .red
        print("🎨 View controller created with red background")
        
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        print("✅ Window made key and visible")
        
        return true
    }
}
