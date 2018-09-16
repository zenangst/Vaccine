#if os(macOS)
import Cocoa
public typealias Rect = NSRect
#else
import UIKit
public typealias Rect = CGRect
#endif

extension View {
  /// Swizzle initializers for views if application is compiled in debug mode.
  static func _swizzleViews() {
    #if DEBUG
    DispatchQueue.once(token: "com.zenangst.Vaccine.\(#function)") {
      let originalSelector = #selector(View.init(frame:))
      let swizzledSelector = #selector(View.init(vaccineFrame:))
      Swizzling.swizzle(View.self,
                        originalSelector: originalSelector,
                        swizzledSelector: swizzledSelector)
    }
    #endif
  }

  /// Swizzled init method for view.
  /// This method is used to add a responder for InjectionIII notifications.
  ///
  /// - Parameter frame: The frame rectangle for the view, measured in points.
  @objc public convenience init(vaccineFrame frame: Rect) {
    self.init(vaccineFrame: frame)
    let selector = #selector(View.vaccine_view_injected(_:))
    if responds(to: selector) {
      addInjection(with: selector, invoke: nil)
    }
  }

  /// Respond to InjectionIII notifications.
  /// The notification will be validate to verify that the current view
  /// was injected. If the view responds to `loadView`, that method
  /// will be invoked after the layout constraints have been deactivated.
  /// See `invalidateIfNeededLayoutConstraints` for more information about
  /// how layout constraints are handled via convention.
  ///
  /// - Parameter notification: An InjectionIII notification.
  @objc func vaccine_view_injected(_ notification: Notification) {
    let selector = _Selector("loadView")
    if responds(to: selector), Injection.objectWasInjected(self, in: notification) {
      invalidateIfNeededLayoutConstraints()
      #if os(macOS)
        self.perform(selector)
      #else
        guard Injection.animations else { perform(selector); return }

        let options: UIViewAnimationOptions = [.allowAnimatedContent,
                                               .beginFromCurrentState,
                                               .layoutSubviews]
        UIView.animate(withDuration: 0.3, delay: 0.0, options: options, animations: {
          self.perform(selector)
        }, completion: nil)
      #endif
    }
  }

  /// Create selector using string. This method is meant to silence the warning
  /// that occure when trying to use `Selector` instead of `#selector`.
  ///
  /// - Parameter string: The key that should be used as selector.
  /// - Returns: A selector constructed from the given string parameter.
  private func _Selector(_ string: String) -> Selector {
    return Selector(string)
  }

  /// Invalidate layout constraints if `.layoutConstraints` can be resolved.
  private func invalidateIfNeededLayoutConstraints() {
    let key = "layoutConstraints"
    let selector = _Selector(key)
    if responds(to: selector), let layoutConstraints = value(forKey: key) as? [NSLayoutConstraint] {
      NSLayoutConstraint.deactivate(layoutConstraints)
    }
  }
}
