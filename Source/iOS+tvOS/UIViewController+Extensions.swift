import UIKit

@objc public extension UIViewController {
  private func removeChildViewControllers() {
    childViewControllers.forEach {
      $0.view.removeFromSuperview()
      $0.removeFromParentViewController()
    }
  }

  private func viewDidLoadIfNeeded(_ notification: Notification) {
    guard Injection.isLoaded else { return }
    guard viewControllerWasInjected(notification) else { return }

    NotificationCenter.default.removeObserver(self)

    switch self {
    case let navigationController as UINavigationController:
      break
    case let tabBarController as UITabBarController:
      tabBarController.setViewControllers([], animated: true)
    default:
      removeChildViewControllers()
      removeViewsAndLayers()
    }

    viewDidLoad()
    view.subviews.forEach { view in
      view.setNeedsLayout()
      view.layoutIfNeeded()
      view.setNeedsDisplay()

      (view as? UICollectionView)?.reloadData()
      (view as? UITableView)?.reloadData()
    }

    view.subviews.filter({ $0.frame.size == .zero }).forEach {
      $0.sizeToFit()
    }
  }

  private func removeViewsAndLayers() {
    view.subviews.forEach {
      $0.removeFromSuperview()
    }

    if let sublayers = self.view.layer.sublayers {
      sublayers.forEach { $0.removeFromSuperlayer() }
    }
  }

  @objc func injected(_ notification: Notification) {
    viewDidLoadIfNeeded(notification)
  }
}
