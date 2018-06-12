import Foundation

extension DispatchQueue {
  private  static var tokens = [String]()

  class func once(token: String, closure: () -> Void) {
    objc_sync_enter(self)
    defer { objc_sync_exit(self) }

    guard !tokens.contains(token) else { return }

    tokens.append(token)
    closure()
  }
}
