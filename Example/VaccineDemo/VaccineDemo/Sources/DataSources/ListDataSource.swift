import Vaccine
import UIKit

class ListDataSource: NSObject, UITableViewDataSource {
  weak var tableView: UITableView?
  let models: [Contact]

  init(models: [Contact]) {
    self.models = models
    super.init()
    self.addInjection(with: #selector(injected(_:)))
  }

  @objc open func injected(_ notification: Notification) {
    guard Injection.objectWasInjected(self, notification: notification) else {
      return
    }

    tableView?.reloadData()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return models.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier,
                                             for: indexPath)

    if let listCell = cell as? ListTableViewCell {
      let model = models[indexPath.item]

      listCell.avatarNameLabel.text = ""
      if let first = model.firstName.first {
        listCell.avatarNameLabel.text?.append(first)
      }

      if let first = model.lastName.first {
        listCell.avatarNameLabel.text?.append(first)
      }

      listCell.nameLabel.text = "\(model.firstName) \(model.lastName)"
    }
    return cell
  }
}
