import Foundation

struct ContactDetail {
  enum Kind {
    case email, phone
  }

  let value: String
  let kind: Kind
}
