import Foundation

class ContactController {
  func createContactDetails(from contact: Contact) -> [ContactDetail] {
    var contactDetails = [ContactDetail]()

    for email in contact.emails {
      contactDetails.append(ContactDetail(value: email, kind: .email))
    }

    for phone in contact.phoneNumbers {
      contactDetails.append(ContactDetail(value: phone, kind: .phone))
    }

    if let notes = contact.notes {
      contactDetails.append(ContactDetail(value: notes, kind: .info))
    }

    return contactDetails
  }
}
