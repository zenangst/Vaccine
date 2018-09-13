#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public extension CollectionViewLayout {
  static func _swizzleCollectionLayout() {
    #if DEBUG
    DispatchQueue.once(token: "com.zenangst.Vaccine.\(#function)") {
      let originalSelector = _Selector("init")
      let swizzledSelector = #selector(CollectionViewLayout.init(vaccine_swizzled:))
      Swizzling.swizzle(CollectionViewLayout.self,
                        originalSelector: originalSelector,
                        swizzledSelector: swizzledSelector)
    }
    #endif
  }

  @objc public convenience init(vaccine_swizzled: Bool) {
    self.init(vaccine_swizzled: true)
    Injection.add(observer: self, with: #selector(vaccine_layout_injected(_:)))
  }

  private static func _Selector(_ string: String) -> Selector {
    return Selector(string)
  }

  @objc func vaccine_layout_injected(_ notification: Notification) {
    guard Injection.objectWasInjected(self, in: notification) else { return }
    #if !os(macOS)
    if Injection.animations {
      UIView.animate(withDuration: 0.3) {
        self.invalidateLayout()
      }
    } else {
      invalidateLayout()
    }
    #else
    invalidateLayout()
    #endif
  }
}
