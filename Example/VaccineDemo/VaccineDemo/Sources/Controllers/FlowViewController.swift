import UIKit
import Vaccine

class FlowViewController: UINavigationController, ListViewControllerDelegate {
  func listViewController(_ controller: ListViewController, didSelect contact: Contact) {
    let contactController = ContactController()
    let contactDetails = contactController.createContactDetails(from: contact)
    let detailController = DetailViewController(contactDetails: contactDetails)
    detailController.title = "\(contact.firstName) \(contact.lastName)"
    pushViewController(detailController, animated: true)
  }
}
