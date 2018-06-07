import UIKit
import Vaccine

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var navigationController: UINavigationController?
  var flowController: FlowViewController?
  var screenBounds = UIScreen.main.bounds

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Injection.load(loadApp).add(observer: self, with: #selector(injected(_:)))
    return true
  }

  private func loadApp() {
    let models = [
      Contact(firstName: "Foo", lastName: "Bar")
    ]

    configureApperance()
    let window = UIWindow(frame: screenBounds)
    window.backgroundColor = .white
    let listViewController = ListViewController(models: models)
    let flowController = FlowViewController(listViewController: listViewController)
    self.flowController = flowController
    let navigationController = UINavigationController(rootViewController: flowController)
    if #available(iOS 11.0, *) {
      navigationController.navigationBar.prefersLargeTitles = true
    }
    window.rootViewController = navigationController
    window.makeKeyAndVisible()

    let completion = {
      self.window = window
      self.navigationController = navigationController
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
    screenBounds = UIScreen.device(.iPad(orientation: nil))
    loadApp()

//    guard let flowController = flowController else { return }
//
//    flowController.listViewController(flowController.listViewController,
//                                      didSelect: Contact(firstName: "Anthony", lastName: "Stark"))
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//      UIView.setAnimationsEnabled(true)
//    }
  }
}
