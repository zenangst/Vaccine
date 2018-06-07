import UIKit

public extension UIScreen {
  static func device(_ device: Device) -> CGRect {
    return device.rawValue
  }
}
