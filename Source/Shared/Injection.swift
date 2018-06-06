import Foundation

public class Injection {
  static var resourcePath: String {
    return "/Applications/InjectionIII.app/Contents/Resources"
  }

  static var isLoaded: Bool {
    // Check if tests are running.
    if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
      return true
    }

    return !Bundle.allBundles.filter {
      $0.bundleURL
        .lastPathComponent
        .lowercased()
        .range(of: "injection") != nil }
      .isEmpty
  }

  @discardableResult public static func load(_ closure: (() -> Void)? = nil) -> Injection.Type {
    guard !Injection.isLoaded else { return self }

    #if targetEnvironment(simulator)
      #if os(iOS)
        _ = Bundle(path: "\(Injection.resourcePath)/iOSInjection.bundle")?.load()
      #else
        _ = Bundle(path: "\(Injection.resourcePath)/tvOSInjection.bundle")?.load()
      #endif
    #else
      #if os(macOS)
        _ = Bundle(path: "\(Injection.resourcePath)/macOSInjection.bundle")
      #endif
    #endif

    closure?()

    return self
  }

  private static func addObserver(_ observer: Any,
                                  name: String,
                                  selector: Selector,
                                  object: Any? = nil,
                                  notificationCenter: NotificationCenter = .default) {
    notificationCenter.addObserver(observer,
                                   selector: selector,
                                   name: NSNotification.Name.init(name),
                                   object: object)
  }

  static func object(from notification: Notification) -> NSObject? {
    return (notification.object as? NSArray)?.firstObject as? NSObject
  }

  public static func addViewController(_ viewController: ViewController) {
    viewController.addInjection(with: #selector(ViewController.injected(_:)))
  }

  public static func objectWasInjected(_ object: AnyObject, notification: Notification) -> Bool {
    var result = (notification.object as? NSObject)?.classForCoder == object.classForCoder

    if result == false {
      result = Injection.object(from: notification)?.classForCoder == object.classForCoder
    }

    return result
  }

  public static func add(observer: Any, with selector: Selector) {
    addObserver(observer,
                name: "INJECTION_BUNDLE_NOTIFICATION",
                selector: selector)
  }
}

