import UIKit
import Vaccine

class FlowViewController: UIViewController, ListViewControllerDelegate {
  let listViewController: ListViewController

  init(listViewController: ListViewController) {
    self.listViewController = listViewController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    Injection.addViewController(listViewController)
    listViewController.delegate = self
    configureChildViewControllers()
  }

  private func configureChildViewControllers() {
    willMove(toParentViewController: listViewController)
    addChildViewController(listViewController)
    view.addSubview(listViewController.view)
    didMove(toParentViewController: listViewController)
    title = listViewController.title
  }

  func listViewController(_ controller: ListViewController, didSelect contact: Contact) {
    let detailController = DetailViewController(contact: contact)
    navigationController?.pushViewController(detailController, animated: true)
  }
}
