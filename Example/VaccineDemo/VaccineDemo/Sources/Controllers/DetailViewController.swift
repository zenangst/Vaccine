import UIKit
import Vaccine

class DetailViewController: UIViewController {
  lazy var tableView = UITableView()
  let imageSize: CGFloat = 128
  let dataSource: DetailDataSource

  private var layoutConstraints = [NSLayoutConstraint]()

  init(contactDetails: [ContactDetail]) {
    self.dataSource = DetailDataSource(models: contactDetails)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    NSLayoutConstraint.deactivate(layoutConstraints)
    Injection.addViewController(self)
    configureViewController()
    configureTableView()
    configureConstraints()
  }

  private func configureViewController() {
    view.backgroundColor = .white
  }

  private func configureTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    dataSource.tableView = tableView
    tableView.backgroundColor = .white
    tableView.dataSource = dataSource
    tableView.register(DetailTableViewCell.self,
                       forCellReuseIdentifier: DetailTableViewCell.reuseIdentifier)
    tableView.tableFooterView = UIView()


  }

  private func configureConstraints() {
    var constraints = [NSLayoutConstraint]()
    constraints.append(tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
    constraints.append(tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
    constraints.append(tableView.topAnchor.constraint(equalTo: view.topAnchor))
    constraints.append(tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
    layoutConstraints.append(contentsOf: constraints)
    NSLayoutConstraint.activate(constraints)
  }
}
