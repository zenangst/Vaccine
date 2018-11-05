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
      let originalSelector = #selector(setter: ViewController.view)
      let swizzledSelector = #selector(ViewController.vaccine_setView(_:))
      Swizzling.swizzle(ViewController.self,
                        originalSelector: originalSelector,
                        swizzledSelector: swizzledSelector)
    }
    #endif
  }

  private static func _Selector(_ string: String) -> Selector {
    return Selector(string)
  }

  @objc func vaccine_setView(_ view: View?) {
    if isViewLoaded == false && view != nil {
      Injection.addViewController(self)
    }
    self.vaccine_setView(view)
  }
}
