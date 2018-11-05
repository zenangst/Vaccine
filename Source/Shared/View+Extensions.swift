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

  /// Recursively gather all subviews into a single collection.
  ///
  /// - Returns: A collection of views.
  func subviewsRecursive() -> [View] {
    return subviews + subviews.flatMap { $0.subviewsRecursive() }
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
    let closure = { [weak self] in
      self?.invalidateIfNeededLayoutConstraints()
      self?.perform(selector)
    }

    if responds(to: selector), Injection.objectWasInjected(self, in: notification) {
      #if os(macOS)
        closure()
      #else
        guard Injection.animations else { closure(); return }

      let options: UIView.AnimationOptions = [.allowAnimatedContent,
                                               .beginFromCurrentState,
                                               .layoutSubviews]
        UIView.animate(withDuration: 0.3, delay: 0.0, options: options, animations: {
          closure()
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
  /// If `.layoutConstraints` cannot be resolved, then it will recursively deactivate
  /// constraints on all subviews.
  private func invalidateIfNeededLayoutConstraints() {
    let key = "layoutConstraints"
    if responds(to: _Selector(key)), let layoutConstraints = value(forKey: key) as? [NSLayoutConstraint] {
      NSLayoutConstraint.deactivate(layoutConstraints)
    } else {
      let removeConstraints: (View, NSLayoutConstraint) -> Void = { parentView, constraint in
        if let subview = constraint.firstItem, subview.superview == parentView  {
          NSLayoutConstraint.deactivate([constraint])
          parentView.removeConstraint(constraint)
        }
      }

      #if !os(macOS)
      if let cell = self as? UITableViewCell {
        cell.contentView.constraints.forEach { removeConstraints(cell.contentView, $0) }
      }
      #endif
      constraints.forEach { removeConstraints(self, $0) }
    }
  }
}
