# Vaccine

[![CI Status](https://travis-ci.org/zenangst/Vaccine.svg?branch=master)](https://travis-ci.org/zenangst/Vaccine)
[![Version](https://img.shields.io/cocoapods/v/Vaccine.svg?style=flat)](http://cocoadocs.org/docsets/Vaccine)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Vaccine.svg?style=flat)](http://cocoadocs.org/docsets/Vaccine)
[![Platform](https://img.shields.io/cocoapods/p/Vaccine.svg?style=flat)](http://cocoadocs.org/docsets/Vaccine)
![Swift](https://img.shields.io/badge/%20in-swift%204.0-orange.svg)

## Description

<img src="https://github.com/zenangst/Vaccine/blob/master/Images/Vaccine.png?raw=true" alt="Vaccine Icon" align="right" />

Vaccine is a framework that aims to make your apps immune to recompile-decease.  Vaccine provides a straightforward way to make your application ready for code injection, also known as hot reloading. It provides extensions on application delegates, NSObject and view controllers.

Before you go any further, make sure that you have InjectionIII installed and have understood the core concept for code injection and its limitations.
For more information about InjectionIII, head over to [https://github.com/johnno1962/InjectionIII](https://github.com/johnno1962/InjectionIII).

Vaccine does not cut-out the need to ever recompile, but it opens up for faster iteration and seeing your application change instantly. There will be scenarios where you will simply have to recompile your application in order to see the changes appear. Worth noting is that code injection only works in the simulator and has no effect when running it on a device.

For additional information about how you can incorporate injection into your workflow, check out this [Medium post](https://medium.com/@robnorback/the-secret-to-1-second-compile-times-in-xcode-9de4ec8345a1).

## Usage

The following examples are not meant to be best practices or the defacto way of doing code injection. The examples are based on personal experiences when working on projects that use InjectionIII.

### General tips

To get the most bang for the buck, your view controllers should be implemented with dependency injection, that way you can provide dummy material that is relevant to your current context. This works well when you want to try out different states of your user interface.

### Loading the injection bundle

For InjectionIII to work, you need to load the bundle that is located inside the application bundle. You want to do this as early as possible, preferably as soon as your application is done launching.

```swift
// Loads the injection bundle and registers 
// for injection notifications using `injected` selector.
Injection.load(self.applicationDidLoad)
         .add(observer: self, with: #selector(injected(_:)))
```

### Application delegate

To get the most out of code injection, you need be able to provide your application with a new instance of the class that you are injecting. A good point of entire for injecting code is to reinitialize your application at the application delegate level. It that increases the likely-hood of getting the desired effect of code injection as your root objects are recreated using the newly injected code. It also provides with a point of entry for displaying the target view controller(s) that you are modifying. So what it means in practice is that you can push or present the relevant view controller directly from your application delegate cutting out the need to manually recreating the view controller stack by manually navigating to the view controller you are editing. This is very similar to how playground-driven works, without having to wait for the playground to load or recompile your app as a framework.

```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Injection.load(self.applicationDidLoad).add(observer: self,
                                                with: #selector(injected(_:)))
    return true
  }

  @objc open func injected(_ notification: Notification) {
    applicationDidLoad()
    // Add your view heirarcy creation here.
  }

  private func applicationDidLoad() {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = ViewController()
    window.makeKeyAndVisible()
    self.window = window
  }
}
```

When code is injected, `applicationDidLoad` will be invoked.
It cleans and recreates the entire view heirarcy by creating a new window.

### View controllers

Injecting view controllers is really where InjectionIII shines the most. Vaccine provides extensions to make this easy to setup and maintain. When injection notifications come in, Vaccine will filter out view controllers that do not fill the criteria for being reloaded. It checks if the current view controller belongs to a child view controller, if that turns out to be true, then it will reload the parent view controller to make sure that all necessary controllers are notified about the change.

When a view controller is injected it will do the following:

- Removes the current injection observer
- Remove child view controllers
- Remove views and layers
- Invoked viewDidLoad to properly set up your view controller again
- Invokes layout related methods on all available subviews of the controller's view.
- Invoke sizeToFit on all views that haven't received a size

What you need to do in your view controllers is to listen to the incoming notifications and deregister when it is time to deallocate. Registering should be done in `viewDidLoad` as the notification will temporarily be removed during injection.

```swift
class ViewController: UIViewController {
  deinit {
    Injection.remove(observer: self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    Injection.add(observer: self, with: #selector(injected(_:)))
    // Implementation goes here.
  }
}
```

When a view controller gets injected, it will invoke everything inside `viewDidLoad`,
so any changes that you make to the controller should be rendered on screen.

## Views

Injection views are similar to view controllers, except that they don't have a conventional method that you override to build your custom implementation. Usually, you do everything inside the initializer. To make your view injection friendly, you should move the implementation from the initializer into a separate method that you can call whenever that view's class is injected.

```swift
class CustomView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    addInjection(with: #selector(injected(_:)))
    loadView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    removeInjection()
  }

  private func loadView() {
    // Your code goes here.
  }

  @objc open func injected(_ notification: Notification) {
    loadView()
  }
}
```

If you feel like this is a lot of code to write for all views that you create, I recommend
creating an Xcode template for creating views.

## Auto layout constraints

Adding additional constraints can quickly land you in a situation where your layout constraints are ambiguous. One way to tackle this issue is to gather all your views constraints into an array, and at the top of your setup method, you simply set these constraints to be deactivated. That way you can add additional constraints by continuing to inject, and the latest pair are the only ones that will be active and in use.

```swift
class CustomView: UIView {
  private var layoutConstraints = [NSLayoutConstraint]()
  
  private func loadView() {
    NSLayoutConstraint.deactivate(layoutConstraints)
    // Your code goes here.
  }
}
```


## Installation

**Vaccine** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Vaccine'
```

**Vaccine** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install just write into your Cartfile:

```ruby
github "zenangst/Vaccine"
```

**Vaccine** can also be installed manually. Just download and drop `Sources` folders in your project.

## Author

Christoffer Winterkvist, christoffer@winterkvist.com

## Contributing

We would love you to contribute to **Vaccine**, check the [CONTRIBUTING](https://github.com/zenangst/Vaccine/blob/master/CONTRIBUTING.md) file for more info.

## License

**Vaccine** is available under the MIT license. See the [LICENSE](https://github.com/zenangst/Vaccine/blob/master/LICENSE.md) file for more info.
