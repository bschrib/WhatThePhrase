import SwiftUI

class LaunchScreenHostingController: UIHostingController<LaunchScreen> {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
