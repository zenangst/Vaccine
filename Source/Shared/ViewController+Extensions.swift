#if os(macOS)
  import Cocoa
#else
  import UIKit
#endif

extension ViewController {
  func viewControllerWasInjected(_ notification: Notification) -> Bool {
    if Injection.objectWasInjected(self, notification: notification) { return true }
    guard let object = Injection.object(from: notification) else {
      return false
    }

    var shouldRespondToInjection: Bool = false

    /// Check if parent view controller should be injected.
    if !childViewControllers.isEmpty {
      for childViewController in childViewControllers {
        if object.classForCoder == childViewController.classForCoder {
          shouldRespondToInjection = true
          break
        }
      }
    }

    /// Check if object matches self.
    if !shouldRespondToInjection {
      shouldRespondToInjection = object.classForCoder == self.classForCoder
    }

    return shouldRespondToInjection
  }

  public static func _swizzleViewControllers() {
    #if DEBUG
      DispatchQueue.once(token: "com.zenangst.Vaccine.swizzleViewControllers") {
        let originalSelector = #selector(loadView)
        let swizzledSelector = #selector(vaccine_loadView)
        Swizzling.swizzle(ViewController.self,
                          originalSelector: originalSelector,
                          swizzledSelector: swizzledSelector)
      }
    #endif
  }

  @objc func vaccine_loadView() {
    vaccine_loadView()
    Injection.addViewController(self)
  }
}
