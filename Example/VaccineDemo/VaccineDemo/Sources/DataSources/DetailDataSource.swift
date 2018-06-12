import UIKit
import Vaccine

class DetailDataSource: NSObject, UITableViewDataSource {
  weak var tableView: UITableView?
  let models: [ContactDetail]

  init(models: [ContactDetail]) {
    self.models = models
    super.init()
    addInjection(with: #selector(injected(_:)))
  }

  @objc open func injected(_ notification: Notification) {
    tableView?.reloadData()
  }

  private func model(at indexPath: IndexPath) -> ContactDetail {
    return models[indexPath.item]
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return models.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableViewCell.reuseIdentifier,
                                             for: indexPath)

    if let view = cell as? DetailTableViewCell {
      let contactDetail = model(at: indexPath)

      switch contactDetail.kind {
      case .info:
        view.textLabel?.text = "Info"
      case .email:
        view.textLabel?.text = "Email"
      case .phone:
        view.textLabel?.text = "Phone"
      }

      view.detailTextLabel?.text = contactDetail.value
    }

    return cell
  }
}
