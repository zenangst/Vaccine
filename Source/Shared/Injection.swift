import Foundation

/// A static class that makes it easier to add run-time code injection.
/// It removes boilerplate code with setting up notification center observers.
///
/// Application delegate example:
///
/// It will invoke `applicationDidLoad` after the InjectionIII bundle is loaded and
/// add an observer that will invoke `injected(_ notification: Notification)` when
/// new source code is injected into the app.
/// ```
/// Injection.load(applicationDidLoad)
///          .add(observer: self, with: #selector(injected(_:)))
/// ```
///
/// View controller example:
///
/// Will add injection to the view controller and use the built-in
/// view controller extension from properly reloading the controllers
/// state. See view controller extension for more information.
/// View controllers that use the extension will only be trigger
/// if they were saved, if any other object is injected these updates
/// are ignored. This is meant to reduce the amount of work that
/// needs to be processed when injection occures.
///
/// ```
/// func viewDidLoad() {
///   Injection.addViewController(self)
/// }
/// ```
///
/// Custom object example:
///
/// ```
/// Injection.addObserver(observer: self, with: #selector(injected(_:)))
/// ```
///
public class Injection {
  /// The path to the resource folder of the InjectionIII.app.
  static var resourcePath: String {
    return "/Applications/InjectionIII.app/Contents/Resources"
  }

  /// Deteremins if the InjectionIII bundle is loaded.
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

  /// Load the InjectionIII bundle.
  ///
  /// - Parameter closure: Optional closure that will be invoked after the bundle has been loaded.
  ///                      NOTE: Will not be invoked if bundled is not found.
  /// - Returns: An instance of `self` in order to make the function chainable.
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

  /// Add observer to notification center.
  ///
  /// - Parameters:
  ///   - observer: The observer that should be added to the notification center.
  ///   - name: The name of the notification that should be observed.
  ///   - selector: The selector that should be invoked when the notification is triggered.
  ///   - object: An optional object that will be sent along with the notification, defaults to `nil`.
  ///   - notificationCenter: The notification center that should be used to add the observer.
  ///                         Defaults is `.default`.
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

  /// Resolve object from notification.
  ///
  /// - Parameter notification: The notification that should be used to resolve the object.
  /// - Returns: An `NSObject` if the notifications object is an array and the first object in the
  ///            array is an `NSObject`.
  static func object(from notification: Notification) -> NSObject? {
    return (notification.object as? NSArray)?.firstObject as? NSObject
  }

  /// Adds built-in notification mechanism to a view controller.
  /// See view controller extension for more details.
  ///
  /// - Parameter viewController: The view controller that should be used with injection.
  public static func addViewController(_ viewController: ViewController) {
    viewController.addInjection(with: #selector(ViewController.injected(_:)))
  }

  /// Check if the current object was apart of the notification's object.
  ///
  /// - Parameters:
  ///   - object: The object that should be used for comparison.
  ///   - notification: The notification that will be used for resolving the object.
  /// - Returns: True if the object matches the object embedded in the notification.
  public static func objectWasInjected(_ object: AnyObject, notification: Notification) -> Bool {
    var result = (notification.object as? NSObject)?.classForCoder == object.classForCoder

    if result == false {
      result = Injection.object(from: notification)?.classForCoder == object.classForCoder
    }

    return result
  }

  /// Add InjectionIII notification observer with selection.
  ///
  /// - Parameters:
  ///   - observer: The observer that should listen to InjectionIII type notification.
  ///   - selector: The selector that should be used on the observer.
  public static func add(observer: Any, with selector: Selector) {
    addObserver(observer,
                name: "INJECTION_BUNDLE_NOTIFICATION",
                selector: selector)
  }
}

