#if os(macOS)
  import Cocoa
#else
  import UIKit
#endif

extension ViewController {
  public static func _swizzleViewControllers() {
    #if DEBUG
      DispatchQueue.once(token: "com.zenangst.Vaccine.swizzleViewControllers") {
        let originalSelector = #selector(viewDidLoad)
        let swizzledSelector = #selector(vaccine_viewDidLoad)
        Swizzling.swizzle(ViewController.self,
                          originalSelector: originalSelector,
                          swizzledSelector: swizzledSelector)
      }
    #endif
  }

  @objc func vaccine_viewDidLoad() {
    vaccine_viewDidLoad()
    Injection.addViewController(self)
  }
}
