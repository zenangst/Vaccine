#if os(macOS)
  import Cocoa
#else
  import UIKit
#endif

extension ViewController {

  #if swift(>=4.2)
    func childViewControllersRecursive() -> [ViewController] {
      return children + children.flatMap { $0.childViewControllersRecursive() }
    }
  #else
    func childViewControllersRecursive() -> [ViewController] {
      return childViewControllers + childViewControllers.flatMap { $0.childViewControllersRecursive() }
    }
  #endif

  public static func _swizzleViewControllers() {
    #if DEBUG
      DispatchQueue.once(token: "com.zenangst.Vaccine.\(#function)") {
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
