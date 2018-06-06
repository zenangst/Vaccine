#if os(macOS)
  import Cocoa
  public typealias ViewController = NSViewController
#else
  import UIKit
  public typealias ViewController = UIViewController
#endif
