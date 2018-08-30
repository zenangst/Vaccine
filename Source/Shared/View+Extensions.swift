#if os(macOS)
import Cocoa
public typealias Rect = NSRect
#else
import UIKit
public typealias Rect = CGRect
#endif

extension View {
  // Swizzle initializers for views if application is compiled in debug mode.
  static func _swizzleViews() {
    #if DEBUG
    DispatchQueue.once(token: "com.zenangst.Vaccine.swizzleViews") {
      let originalSelector = #selector(View.init(frame:))
      let swizzledSelector = #selector(View.init(vaccineFrame:))
      Swizzling.swizzle(View.self,
                        originalSelector: originalSelector,
                        swizzledSelector: swizzledSelector)
    }
    #endif
  }

  @objc public convenience init(vaccineFrame frame: Rect) {
    self.init(vaccineFrame: frame)
    let selector = #selector(View.vaccine_view_injected(_:))
    if responds(to: selector) {
      addInjection(with: selector, invoke: nil)
    }
  }

  @objc func vaccine_view_injected(_ notification: Notification) {
    let selector = Selector("loadView")
    if responds(to: selector), Injection.objectWasInjected(self, in: notification) {
      perform(selector)
    }
  }
}
