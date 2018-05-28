import UIKit

public extension UIApplicationDelegate {
  func loadInjection(_ closure: (() -> Void)? = nil) {
    guard !Injection.isLoaded else { return }

    #if targetEnvironment(simulator)
      #if os(iOS)
        _ = Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
      #else
        _ = Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/tvOSInjection.bundle")?.load()
      #endif
    #endif

    closure?()
  }
}
