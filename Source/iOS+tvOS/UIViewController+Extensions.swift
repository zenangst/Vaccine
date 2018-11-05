import UIKit

@objc public extension UIViewController {
  /// Validate if the current class was injected by checking the contents
  /// of the notification.
  ///
  /// - Parameter notification: A standard InjectionIII notification
  private func viewDidLoadIfNeeded(_ notification: Notification) {
    guard Injection.isLoaded else { return }
    guard Injection.viewControllerWasInjected(self, in: notification) else { return }
    if !Injection.swizzleViewControllers {
      NotificationCenter.default.removeObserver(self)
    }

    performInjection()
  }

  /// Invoke all injection related methods in sequence.
  /// If this method is invoked with animations enabled,
  /// a snapshot of the current view will be created and
  /// added to the applications window in order to nicely
  /// transition to the new controller view state.
  private func performInjection() {
    let options: UIView.AnimationOptions = [.allowAnimatedContent,
                                            .beginFromCurrentState,
                                            .layoutSubviews]
    if Injection.animations, let snapshot = self.view.snapshotView(afterScreenUpdates: false) {
      let maskView = UIView()
      maskView.frame.size = snapshot.frame.size
      maskView.frame.origin.y = navigationController?.navigationBar.frame.maxY ?? 0
      maskView.backgroundColor = .white
      snapshot.mask = maskView
      view.window?.addSubview(snapshot)
      let oldScrollViews = indexScrollViews()

      if nibName == nil {
        resetViewControllerState()
        rebuildViewControllerState()
      } else {
        rebuildNibViewControllerState()
      }

      syncOldScrollViews(oldScrollViews, with: indexScrollViews())
      UIView.animate(withDuration: 0.25, delay: 0.0, options: options, animations: {
        snapshot.alpha = 0.0
      }) { _ in
        snapshot.removeFromSuperview()
      }
    } else {
      let scrollViews = indexScrollViews()
      lockScreenUpdates(!scrollViews.isEmpty)

      if nibName == nil {
        resetViewControllerState()
        rebuildViewControllerState()
      } else {
        rebuildNibViewControllerState()
      }

      unlockScreenUpdates(!scrollViews.isEmpty, scrollViews: scrollViews)
    }
  }

  private func rebuildNibViewControllerState() {
    let subviews = view.subviewsRecursive()

    for case let tableView as UITableView in subviews {
      tableView.reloadData()
    }

    for case let collectionView as UICollectionView in subviews {
      collectionView.reloadData()
    }

    viewWillAppear(false)
    viewDidAppear(false)
  }

  /// Will invoke `viewDidLoad` to run view controllers setup operations.
  /// In addition, it will force all subview to layout and collection & table views
  /// to reload. This is to make sure that we are displaying the latest changes.
  private func rebuildViewControllerState() {
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

  /// Lock screen updates using a `CATransaction`.
  ///
  /// - Parameter shouldLock: A boolean value indicating if the method should
  ///                         be invoked or not. This is determined by the
  ///                         amount of child view controllers in the controller.
  private func lockScreenUpdates(_ shouldLock: Bool) {
    guard shouldLock else { return }
    CATransaction.begin()
    CATransaction.lock()
  }

  /// Unlock screen updates using a `CATransaction`.
  ///
  /// - Parameters:
  /// - Parameter shouldLock: A boolean value indicating if the method should
  ///                         be invoked or not. This is determined by the
  ///                         amount of child view controllers in the controller.
  ///   - scrollViews: A dictionary of scroll views related to the view controller.
  private func unlockScreenUpdates(_ shouldUnlock: Bool, scrollViews: [UIScrollView]) {
    guard shouldUnlock else { return }
    syncOldScrollViews(scrollViews, with: indexScrollViews())
    let nearFuture = DispatchTime.now() + 0.3
    DispatchQueue.main.asyncAfter(deadline: nearFuture) {
      CATransaction.unlock()
      CATransaction.commit()
    }
  }

  /// Create an index of the content offsets for all underlying scroll views.
  ///
  /// - Returns: A dictionary of scroll views and their current origin.
  private func indexScrollViews() -> [UIScrollView] {
    var scrollViews = [UIScrollView]()
    for case let scrollView as UIScrollView in view.subviews {
      scrollViews.append(scrollView)
    }

    if let parentViewController = parent {
      for case let scrollView as UIScrollView in parentViewController.view.subviews {
        scrollViews.append(scrollView)
      }
    }

    let childControllers: [UIViewController]
    #if swift(>=4.2)
      childControllers = children
    #else
      childControllers = childViewControllers
    #endif

    for childViewController in childControllers {
      for case let scrollView as UIScrollView in childViewController.view.subviews {
        scrollViews.append(scrollView)
      }
    }

    return scrollViews
  }

  /// Sync two scroll views content offset if they are of the same type.
  ///
  /// - Parameters:
  ///   - oldScrollViews: An array of scroll views from before the injection occured.
  ///   - newScrollViews: An array of new scroll views after the injection occured.
  private func syncOldScrollViews(_ oldScrollViews: [UIScrollView], with newScrollViews: [UIScrollView]) {
    for (offset, scrollView) in newScrollViews.enumerated() {
      if offset < oldScrollViews.count {
        let oldScrollView = oldScrollViews[offset]
        if type(of: scrollView) == type(of: oldScrollView) {
          scrollView.contentOffset = oldScrollView.contentOffset
        }
      }
    }
  }

  /// Removes all child view controllers.
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

  /// Clean up view hierarchy by removing child view controllers, view and layers.
  private func resetViewControllerState() {
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

  /// Removes all views and layers from a view.
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
