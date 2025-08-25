import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle LinkedIn OAuth callback
        if url.scheme == "linkedinverifier" {
            // Post notification to handle the callback
            NotificationCenter.default.post(name: .linkedInCallback, object: url)
            return true
        }
        return false
    }
}

extension Notification.Name {
    static let linkedInCallback = Notification.Name("linkedInCallback")
}