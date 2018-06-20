#if os(macOS)
  import Cocoa
#else
  import UIKit
#endif

extension ViewController {
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
