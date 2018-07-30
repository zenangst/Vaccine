import UIKit

@objc public extension UIViewController {
  private func removeChildViewControllers() {
    childViewControllers.forEach {
      $0.view.removeFromSuperview()
      $0.removeFromParentViewController()
    }
  }

  private func processScreenUpdates(_ shouldLock: Bool, scrollViews: [UIScrollView: CGPoint]) {
    guard shouldLock else { return }
    CATransaction.begin()
    CATransaction.lock()
    scrollViews.forEach { $0.key.contentOffset = $0.value }
    CATransaction.unlock()
    CATransaction.commit()
  }

  private func viewDidLoadIfNeeded(_ notification: Notification) {
    guard Injection.isLoaded else { return }
    guard Injection.viewControllerWasInjected(self, in: notification) else { return }

    if !Injection.swizzleViewControllers {
      NotificationCenter.default.removeObserver(self)
    }

    var scrollViews = [UIScrollView: CGPoint]()
    for case let scrollView as UIScrollView in view.subviews {
      scrollViews[scrollView] = scrollView.contentOffset
    }

    switch self {
    case _ as UINavigationController:
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
    processScreenUpdates(!scrollViews.isEmpty, scrollViews: scrollViews)
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
