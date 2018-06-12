import Foundation

class Swizzling {
  static func swizzle(_ cls: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    let originalMethod = class_getInstanceMethod(cls, originalSelector)
    let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
    method_exchangeImplementations(originalMethod!, swizzledMethod!)
  }
}
