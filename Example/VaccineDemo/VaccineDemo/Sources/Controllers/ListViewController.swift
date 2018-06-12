import UIKit
import Vaccine

protocol ListViewControllerDelegate: class {
  func listViewController(_ controller: ListViewController, didSelect contact: Contact)
}

class ListViewController: UIViewController, UITableViewDelegate {
  weak var delegate: ListViewControllerDelegate?
  let models: [Contact]
  lazy var tableView = UITableView()
  lazy var dataSource = ListDataSource(models: models)
  private var layoutConstraints = [NSLayoutConstraint]()

  init(models: [Contact]) {
    self.models = models
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    NSLayoutConstraint.deactivate(layoutConstraints)
    Injection.addViewController(self)
    configureController()
    configureViews()
    configureConstraints()
  }

  private func configureController() {
    title = "Contacts"
  }

  private func configureViews() {
    view.addSubview(tableView)
    view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
    dataSource.tableView = tableView
    tableView.backgroundColor = .white
    tableView.dataSource = dataSource
    tableView.delegate = self
    tableView.rowHeight = 80
    tableView.register(ListTableViewCell.self,
                       forCellReuseIdentifier: ListTableViewCell.reuseIdentifier)
    tableView.tableFooterView = UIView()
  }

  private func configureConstraints() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    var constraints = [NSLayoutConstraint]()
    constraints.append(tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
    constraints.append(tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
    if #available(iOS 11.0, *) {
      constraints.append(tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
    } else {
      constraints.append(tableView.topAnchor.constraint(equalTo: view.topAnchor))
    }
    constraints.append(tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
    NSLayoutConstraint.activate(constraints)
    layoutConstraints.append(contentsOf: constraints)
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let contact = dataSource.models[indexPath.item]
    delegate?.listViewController(self, didSelect: contact)
  }
}
