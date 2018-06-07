import UIKit
import Vaccine

class ListTableViewCell: UITableViewCell {
  static var reuseIdentifier: String {
    return String(describing: ListTableViewCell.self)
  }

  private var layoutConstraints = [NSLayoutConstraint]()
  lazy var avatarImageView = UIImageView()
  lazy var avatarNameLabel = UILabel()
  lazy var nameLabel = UILabel()

  let imageSize: CGFloat = 48

  // MARK: - Initializer

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
    addInjection(with: #selector(injected(_:)))
    loadView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  override func layoutSubviews() {
    avatarImageView.layer.cornerRadius = imageSize / 2
  }

  // MARK: - Initial load

  private func loadView() {
    contentView.addSubview(avatarImageView)
    contentView.addSubview(avatarNameLabel)
    contentView.addSubview(nameLabel)
    configureViews()
    configureConstraints()
  }

  private func configureViews() {
    avatarImageView.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
    backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
    contentView.backgroundColor = .white
    nameLabel.font = .systemFont(ofSize: 20)
    nameLabel.textColor = .black
    avatarNameLabel.font = UIFont.boldSystemFont(ofSize: 15)
    avatarNameLabel.textColor = .white
    avatarNameLabel.textAlignment = .center
  }

  private func configureConstraints() {
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

    var constraints = [NSLayoutConstraint]()
    constraints.append(contentView.leadingAnchor.constraint(equalTo: leadingAnchor))
    constraints.append(contentView.trailingAnchor.constraint(equalTo: trailingAnchor))
    constraints.append(contentView.topAnchor.constraint(equalTo: topAnchor))
    constraints.append(contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1))
    constraints.append(avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
    constraints.append(avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20))
    constraints.append(avatarImageView.widthAnchor.constraint(equalToConstant: imageSize))
    constraints.append(avatarImageView.heightAnchor.constraint(equalToConstant: imageSize))
    constraints.append(avatarNameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor))
    constraints.append(avatarNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor))
    constraints.append(avatarNameLabel.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor))
    constraints.append(avatarNameLabel.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor))
    constraints.append(nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor))
    constraints.append(nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10))
    NSLayoutConstraint.activate(constraints)
    layoutConstraints.append(contentsOf: constraints)
  }

  // MARK: - Injection

  @objc open func injected(_ notification: Notification) {
    NSLayoutConstraint.deactivate(layoutConstraints)
    loadView()
  }
}
