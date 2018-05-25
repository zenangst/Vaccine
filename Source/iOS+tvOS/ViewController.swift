import UIKit

open class ViewController: UIViewController {
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  open override func viewDidLoad() {
    super.viewDidLoad()
    Injection.add(observer: self, with: #selector(injected(_:)))
  }
}
