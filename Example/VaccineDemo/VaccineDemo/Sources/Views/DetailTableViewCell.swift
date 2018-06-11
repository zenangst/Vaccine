import UIKit
import Vaccine

class DetailTableViewCell: UITableViewCell {
  static var reuseIdentifier: String {
    return String(describing: ListTableViewCell.self)
  }

  private var layoutConstraints = [NSLayoutConstraint?]()

  // MARK: - Initializer

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    addInjection(with: #selector(injected(_:)))
    loadView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Initial load

  private func loadView() {
    NSLayoutConstraint.deactivate(layoutConstraints.compactMap({ $0 }))
  }

  // MARK: - Injection

  @objc open func injected(_ notification: Notification) {
    loadView()
  }
}
