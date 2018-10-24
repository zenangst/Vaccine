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


  #if !os(macOS)
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
  #else
    public static func _swizzleViewControllers() {
      #if DEBUG
      DispatchQueue.once(token: "com.zenangst.Vaccine.\(#function)") {
        let originalSelector = #selector(ViewController.init(nibName:bundle:))
        let swizzledSelector = #selector(ViewController.init(vaccine_swizzled_nibName:bundle:))
        Swizzling.swizzle(ViewController.self,
                          originalSelector: originalSelector,
                          swizzledSelector: swizzledSelector)
      }
      #endif
    }

    private static func _Selector(_ string: String) -> Selector {
      return Selector(string)
    }

  @objc public convenience init(vaccine_swizzled_nibName: NSNib.Name?, bundle: Bundle?) {
      self.init(vaccine_swizzled_nibName: vaccine_swizzled_nibName, bundle: bundle)
      Injection.addViewController(self)
    }
  #endif
}
