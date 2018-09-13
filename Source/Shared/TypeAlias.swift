#if os(macOS)
import Cocoa
public typealias CollectionView = NSCollectionView
public typealias CollectionViewDataSource = NSCollectionViewDataSource
public typealias CollectionViewLayout = NSCollectionViewLayout
public typealias TableView = NSTableView
public typealias TableViewDataSource = NSTableViewDataSource

/// A view extension that is used to add swizzling of the `init(_ frame: CGRect)` in order
/// to automatically subscribe to injection notifications. When a view is injected,
/// the notification from `InjectionIII` will be validate to check if the current class
/// was injected or not. It does this by looking at the payload of the notification,
/// more precisely it examines the `.object` of the notification.
///
/// If the view that gets injected has a method called `loadView`, this method will be
/// invoked when the new class is injected. That way the setup for the view is perform
/// and the new changes will appear inside your view.
///
/// - Note:
/// Swizzling only works if the application is built with the variable `DEBUG` being set.
/// It has no effect when running the application in production.
///
/// For `loadView` to work, it needs to be visible inside of Objective-C runtime.
/// You will have to annotate this function with `@objc` in order for injection
/// to perform the selector.
///
///     @objc private func loadView() {}
public typealias View = NSView
public typealias ViewController = NSViewController
#else
import UIKit
public typealias CollectionView = UICollectionView
public typealias CollectionViewDataSource = UICollectionViewDataSource
public typealias CollectionViewLayout = UICollectionViewLayout
public typealias TableView = UITableView
public typealias TableViewDataSource = UITableViewDataSource
/// A view extension that is used to add swizzling of the `init(_ frame: CGRect)` in order
/// to automatically subscribe to injection notifications. When a view is injected,
/// the notification from `InjectionIII` will be validate to check if the current class
/// was injected or not. It does this by looking at the payload of the notification,
/// more precisely it examines the `.object` of the notification.
///
/// If the view that gets injected has a method called `loadView`, this method will be
/// invoked when the new class is injected. That way the setup for the view is perform
/// and the new changes will appear inside your view.
///
/// - Note:
/// Swizzling only works if the application is built with the variable `DEBUG` being set.
/// It has no effect when running the application in production.
///
/// For `loadView` to work, it needs to be visible inside of Objective-C runtime.
/// You will have to annotate this function with `@objc` in order for injection
/// to perform the selector.
///
///     @objc private func loadView() {}
public typealias View = UIView
public typealias ViewController = UIViewController
#endif
