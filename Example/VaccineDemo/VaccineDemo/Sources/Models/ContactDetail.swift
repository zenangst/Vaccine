import Foundation

struct ContactDetail {
  enum Kind {
    case info, email, phone
  }

  let value: String
  let kind: Kind
}
