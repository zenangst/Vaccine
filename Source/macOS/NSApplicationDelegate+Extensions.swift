import Cocoa

public extension NSApplicationDelegate {
  func loadInjection(_ closure: (() -> Void)? = nil) {
    guard !Injection.isLoaded else { return }

    defer { closure?() }

    _ = Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection.bundle")
  }
}
