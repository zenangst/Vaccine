import Foundation

struct Contact {
  let firstName: String
  let lastName: String
  let phoneNumbers: [String]
  let emails: [String]
  let notes: String?

  init(firstName: String, lastName: String = "",
       phoneNumbers: [String] = [], emails: [String] = [],
       notes: String = "") {
    self.firstName = firstName
    self.lastName = lastName
    self.phoneNumbers = phoneNumbers
    self.emails = emails
    self.notes = notes
  }
}
