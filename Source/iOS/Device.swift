import UIKit

public enum Device {
  public enum Orientation {
    case portrait, landscape
  }

  case iPhone4(orientation: Orientation?)
  case iPhoneSE(orientation: Orientation?)
  case iPhone8(orientation: Orientation?)
  case iPhone8Plus(orientation: Orientation?)
  case iPhoneX(orientation: Orientation?)
  case iPad(orientation: Orientation?)

  var size: CGSize {
    switch self {
    case .iPhone4(_):
      return .init(width: 240, height: 320)
    case .iPhoneSE(_):
      return .init(width: 320, height: 568)
    case .iPhone8(_):
      return .init(width: 375, height: 667)
    case .iPhone8Plus(_):
      return .init(width: 414, height: 736)
    case .iPhoneX(_):
      return .init(width: 375, height: 812)
    case .iPad(_):
      return .init(width: 768, height: 1024)
    }
  }

  var rawValue: CGRect {
    var result: CGRect = .zero

    switch self {
    case .iPhone4(let orientation),
         .iPhoneSE(let orientation),
         .iPhone8(let orientation),
         .iPhone8Plus(let orientation),
         .iPhoneX(let orientation),
         .iPad(let orientation):
      switch orientation {
      case .portrait?:
        result.size = CGSize(width: self.size.width, height: self.size.height)
      case .landscape?:
        result.size = CGSize(width: self.size.height, height: self.size.width)
      case .none:
        switch UIDevice.current.orientation {
        case .faceDown, .faceUp, .portrait, .portraitUpsideDown, .unknown:
          result.size = CGSize(width: self.size.width, height: self.size.height)
        case .landscapeLeft, .landscapeRight:
          result.size = CGSize(width: self.size.height, height: self.size.width)
        }
      }
    }

    result.origin.x = UIScreen.main.bounds.width / 2 - result.width / 2
    result.origin.y = UIScreen.main.bounds.height / 2 - result.height / 2

    return result
  }
}
