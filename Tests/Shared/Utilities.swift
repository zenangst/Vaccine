import Foundation

class Utilities {
  func triggerInjection(_ object: AnyObject? = nil) {
    let notificationName = "INJECTION_BUNDLE_NOTIFICATION"
    NotificationCenter.default.post(name: NSNotification.Name.init(notificationName),
      object: object)
  }
}
