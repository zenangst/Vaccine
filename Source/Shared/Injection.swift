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
  /// The file bundle
  static func bundle(version: String = "") -> String {
    #if os(iOS)
      return "iOSInjection\(version).bundle"
    #elseif os(tvOS)
      return "tvOSInjection\(version).bundle"
    #else
      return "macOSInjection\(version).bundle"
    #endif
  }

  /// The path to the resource folder of the InjectionIII.app.
  static var resourcePath: String {
    return "/Applications/InjectionIII.app/Contents/Resources"
  }

  // The path to the injection bundle.
  static func bundlePath(version: String = "") -> String {
    return "\(Injection.resourcePath)/\(Injection.bundle(version: version))"
  }

  static var swizzleViews: Bool = false {
    didSet { if swizzleViews { View._swizzleViews() } }
  }

  static var swizzleCollectionViews: Bool = false {
    didSet { if swizzleTableViews { CollectionView._swizzleCollectionViews() } }
  }

  static var swizzleCollectionViewLayouts: Bool = false {
    didSet { if swizzleTableViews { CollectionViewLayout._swizzleCollectionLayout() } }
  }

  static var swizzleTableViews: Bool = false {
    didSet { if swizzleTableViews { TableView._swizzleTableViews() } }
  }

  static var swizzleViewControllers: Bool = false {
    didSet { if swizzleViewControllers { ViewController._swizzleViewControllers() } }
  }

  static var animations: Bool = false

  /// Determines if the InjectionIII bundle is loaded by searching all loaded bundles.
  static var isLoaded: Bool {
    // Check if tests are running.
    if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
      return true
    }

    // Search for injection in the loaded bundles.
    var result: Bool = false
    for bundle in Bundle.allBundles {
      let url = bundle.bundleURL
        .lastPathComponent
        .lowercased()
      if url.range(of: "injection") != nil {
        result = true
        break
      }
    }

    return result
  }

  /// Load the InjectionIII bundle and optionally perform post actions when the bundle
  /// is finished loading. The handler is called even if the bundle cannot be found.
  ///
  /// - Parameters:
  ///   - handler: Optional closure that will be invoked after the bundle has been loaded.
  ///   - swizzling: Determines if swizzling should be applied, defaults to `true`.
  ///   - animations: Determines if animations should be used for view and view controller injections.
  ///                 Defaults to `true`
  /// - Returns: An instance of `self` in order to make the function chainable.
  ///
  /// - Note: The bundle will only load if the application is running in the simulator.
  ///         Swizzling is only allowed from applications that have the `DEBUG` flag set.
  @discardableResult public static func load(then handler: (() -> Void)? = nil,
                                             swizzling: Bool = true,
                                             animations: Bool = true) -> Injection.Type {
    defer { handler?() }
    guard !Injection.isLoaded else { return self }

    #if targetEnvironment(simulator) || os(macOS)
    let loadedXcode10 = Bundle(path: Injection.bundlePath(version: "10"))?.load() ?? false
    if !loadedXcode10 {
      Bundle(path: Injection.bundlePath())?.load()
    }
    #endif

    swizzleViewControllers = swizzling
    swizzleViews = swizzling
    swizzleTableViews = swizzling
    swizzleCollectionViews = swizzling
    swizzleCollectionViewLayouts = swizzling
    self.animations = animations
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
  public static func objectWasInjected(_ object: AnyObject, in notification: Notification) -> Bool {
    var result = (notification.object as? NSObject)?.classForCoder == object.classForCoder

    if result == false {
      let resolvedObject = Injection.object(from: notification)
      result = resolvedObject?.classForCoder == object.classForCoder
    }

    return result
  }

  static func viewControllerWasInjected(_ viewController: ViewController,
                                        in notification: Notification) -> Bool {
    
    if objectWasInjected(self, in: notification) { return true }
    guard let object = object(from: notification) else {
      return false
    }

    var shouldRespondToInjection: Bool = false
    let childViewControllers = viewController.childViewControllersRecursive()

    /// Check if parent view controller should be injected.
    if !childViewControllers.isEmpty {
      for childViewController in childViewControllers {
        if object.classForCoder == childViewController.classForCoder {
          shouldRespondToInjection = true
          break
        }
      }
    }

    /// Check if object matches self.
    if !shouldRespondToInjection {
      shouldRespondToInjection = object.classForCoder == viewController.classForCoder
    }


    let objectName = "\(object.classForCoder)".lowercased()

    /// Do a dirty match on the class name.
    if !shouldRespondToInjection {
      shouldRespondToInjection = objectName.contains("viewcontroller")
    }

    if !shouldRespondToInjection, objectName.contains("cell") {
      let allSubviews = viewController.view.subviewsRecursive()
      shouldRespondToInjection = !allSubviews.filter({ $0 is TableView || $0 is CollectionView }).isEmpty
    }


    return shouldRespondToInjection
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

