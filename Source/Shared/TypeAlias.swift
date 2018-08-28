#if os(macOS)
  import Cocoa
  public typealias ViewController = NSViewController
  public typealias View = NSView
#else
  import UIKit
  public typealias ViewController = UIViewController
  public typealias View = UIView
#endif
