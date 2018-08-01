import Cocoa

public extension NSApplicationDelegate {
  func loadInjection(_ closure: (() -> Void)? = nil) {
    guard !Injection.isLoaded else { return }
    _ = Bundle(path: Injection.bundlePath)?.load()
    closure?()
  }
}
