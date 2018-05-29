import Foundation

public extension NSObject {
  private func addObserver(name: String,
                           selector: Selector,
                           object: Any? = nil,
                           notificationCenter: NotificationCenter = .default) {
    notificationCenter.addObserver(self,
                                   selector: selector,
                                   name: NSNotification.Name.init(name),
                                   object: object)
  }
  
  func addInjection(with selector: Selector, invoke closure: (() -> Void)? = nil) {
    addObserver(name: "INJECTION_BUNDLE_NOTIFICATION",
                selector: selector)
    closure?()
  }
}
