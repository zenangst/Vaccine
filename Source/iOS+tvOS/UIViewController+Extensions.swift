import UIKit

@objc public extension UIViewController {
  private func removeChildViewControllers() {
    #if swift(>=4.2)
    children.forEach { controller in
      controller.willMove(toParent: nil)
      controller.view.removeFromSuperview()
      controller.removeFromParent()
    }
    #else
    childViewControllers.forEach { controller in
      controller.willMove(toParentViewController: nil)
      controller.view.removeFromSuperview()
      controller.removeFromParentViewController()
    }
    #endif
  }

  private func lockScreenUpdates(_ shouldLock: Bool, scrollViews: [UIScrollView: CGPoint]) {
    guard shouldLock else { return }
    CATransaction.begin()
    CATransaction.lock()
  }

  private func unlockScreenUpdates(_ shouldUnlock: Bool, scrollViews: [UIScrollView: CGPoint]) {
    guard shouldUnlock else { return }
    scrollViews.forEach { $0.key.contentOffset = $0.value }
    let nearFuture = DispatchTime.now() + 0.3
    DispatchQueue.main.asyncAfter(deadline: nearFuture) {
      CATransaction.unlock()
      CATransaction.commit()
    }
  }

  private func viewDidLoadIfNeeded(_ notification: Notification) {
    guard Injection.isLoaded else { return }
    guard Injection.viewControllerWasInjected(self, in: notification) else { return }

    let options: UIViewAnimationOptions = [.allowAnimatedContent,
                                           .beginFromCurrentState,
                                           .layoutSubviews]

    if !Injection.swizzleViewControllers {
      NotificationCenter.default.removeObserver(self)
    }

    if Injection.animations, let snapshot = self.view.snapshotView(afterScreenUpdates: false) {
      let maskView = UIView()
      maskView.frame.size = snapshot.frame.size
      maskView.frame.origin.y = navigationController?.navigationBar.frame.maxY ?? 0
      maskView.backgroundColor = .white
      snapshot.mask = maskView
      view.window?.addSubview(snapshot)
      self.performCleanUp()
      self.performCoreTasks()
      UIView.animate(withDuration: 0.15, delay: 0.0, options: options, animations: {
        snapshot.alpha = 0.0
      }) { _ in
        snapshot.removeFromSuperview()
      }
    } else {
      self.performCleanUp()
      self.performCoreTasks()
    }
  }

  private func performCleanUp() {
    var scrollViews = [UIScrollView: CGPoint]()
    if !Injection.animations {
      defer {
        unlockScreenUpdates(!scrollViews.isEmpty, scrollViews: scrollViews)
      }
      lockScreenUpdates(!scrollViews.isEmpty, scrollViews: scrollViews)
    }

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
  }

  private func performCoreTasks() {
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
