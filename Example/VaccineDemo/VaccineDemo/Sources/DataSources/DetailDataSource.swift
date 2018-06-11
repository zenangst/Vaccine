import UIKit

class DetailDataSource: NSObject, UITableViewDataSource {
  weak var tableView: UITableView?
  let models: [ContactDetail]

  init(models: [ContactDetail]) {
    self.models = models
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
      let contact = model(at: indexPath)
      view.textLabel?.text = "Foo"
      view.detailTextLabel?.text = "Bar"
    }

    return cell
  }
}
