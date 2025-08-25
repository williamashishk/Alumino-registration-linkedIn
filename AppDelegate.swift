import UIKit
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var linkedInManager: LinkedInManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize LinkedIn Manager
        linkedInManager = LinkedInManager()
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ProfileView()
            .environmentObject(linkedInManager!)
        
        // Use a UIHostingController as window root view controller.
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
        
        return true
    }
    
    // Handle custom URL scheme for LinkedIn OAuth
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Check if this is our LinkedIn OAuth callback
        if url.scheme == "alumino" && url.host == "auth" {
            linkedInManager?.handleRedirect(url: url) { success in
                print("LinkedIn OAuth result: \(success)")
            }
            return true
        }
        
        return false
    }
    
    // For iOS 13+ with SceneDelegate, you might need this instead:
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return true
    }
}