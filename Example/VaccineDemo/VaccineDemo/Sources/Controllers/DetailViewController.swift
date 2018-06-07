import UIKit
import Vaccine

class DetailViewController: UIViewController {
  let contact: Contact

  init(contact: Contact) {
    self.contact = contact
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    Injection.addViewController(self)
    configureViews()
    configureViewController()
  }

  private func configureViews() {
    view.backgroundColor = .white
  }

  private func configureViewController() {
    title = "\(contact.firstName) \(contact.lastName)"
  }
}
