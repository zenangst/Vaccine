import UIKit
import Vaccine

class FlowViewController: UINavigationController, ListViewControllerDelegate {
  func listViewController(_ controller: ListViewController, didSelect contact: Contact) {
    let detailController = DetailViewController(contact: contact)
    detailController.title = "\(contact.firstName) \(contact.lastName)"
    pushViewController(detailController, animated: true)
  }
}
