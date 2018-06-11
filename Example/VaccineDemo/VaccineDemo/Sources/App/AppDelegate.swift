import UIKit
import Vaccine

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var flowController: FlowViewController?
  var listViewController: ListViewController?
  var screenBounds = UIScreen.main.bounds

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Injection.load(loadApp).add(observer: self, with: #selector(injected(_:)))
    return true
  }

  private func loadApp() {
    let models = [
      Contact(firstName: "John",
              lastName: "Appleseed",
              phoneNumbers: [
                "(888) 555-5512",
                "(888) 555-1212"],
              emails: ["John-Appleseed@mac.com"]
      )
    ]

    configureApperance()
    let window = UIWindow(frame: screenBounds)
    window.backgroundColor = .white
    let listViewController = ListViewController(models: models)
    let flowController = FlowViewController(rootViewController: listViewController)
    listViewController.delegate = flowController
    self.flowController = flowController
    self.listViewController = listViewController
    if #available(iOS 11.0, *) {
      flowController.navigationBar.prefersLargeTitles = true
    }
    window.rootViewController = flowController
    window.makeKeyAndVisible()

    let completion = {
      self.window = window
    }

    if let currentWindow = self.window {
      UIView.transition(from: currentWindow, to: window,
                        duration: UIView.inheritedAnimationDuration,
                        options: []) { (_) in
                          completion()
      }
    } else {
      completion()
    }
  }

  private func configureApperance() {
    UINavigationBar.appearance().barStyle = .default
    UINavigationBar.appearance().tintColor = .blue
  }
  
  @objc open func injected(_ notification: Notification) {
    // Uncommend this to change the device resolution you want to test with.
//    screenBounds = UIScreen.device(.iPhoneX(orientation: nil))
    loadApp()

    guard let flowController = flowController, let listController = listViewController else { return }

    let contact = Contact(firstName: "John",
                          lastName: "Appleseed",
                          phoneNumbers: [
                            "(888) 555-5512",
                            "(888) 555-1212"],
                          emails: ["John-Appleseed@mac.com"]
    )

    UIView.setAnimationsEnabled(false)
    flowController.listViewController(listController, didSelect: contact)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      UIView.setAnimationsEnabled(true)
    }
  }
}
