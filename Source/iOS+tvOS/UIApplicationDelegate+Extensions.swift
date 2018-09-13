import UIKit

public extension UIApplicationDelegate {
  /// Transition between windows using `UIView.transition` and make window key and visible.
  /// If there is no previous window, the method will return early and call `.makeKeyAndVisible()`
  /// on the new window.
  ///
  /// - Parameters:
  ///   - oldWindow: Optional previous window.
  ///   - window: The new window that should become both key and visible.
  ///   - handler: A completion closure that takes the new window as its argument.
  public func transition(from oldWindow: UIWindow?, to window: UIWindow, then handler: @escaping (UIWindow) -> Void) {
    guard let oldWindow = oldWindow else {
      window.makeKeyAndVisible()
      handler(window)
      return
    }
    window.alpha = 0.0
    window.makeKeyAndVisible()
    UIView.transition(with: oldWindow, duration: 0.3,
                      options: .transitionCrossDissolve, animations: {
                        window.alpha = 1.0
    }, completion: { _ in
      oldWindow.alpha = 0.0
      handler(window)
    })
  }
}
