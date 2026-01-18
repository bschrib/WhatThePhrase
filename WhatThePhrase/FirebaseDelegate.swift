import UIKit
import Firebase
import FirebaseCrashlytics

class FirebaseDelegate: NSObject, UIApplicationDelegate {
    func application(_ _: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Crashlytics.crashlytics()
        return true
    }
}
