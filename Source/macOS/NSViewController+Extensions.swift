import Cocoa

@objc public extension NSViewController {
  private func viewDidLoadIfNeeded(_ notification: Notification) {
    guard Injection.isLoaded else { return }
    guard Injection.viewControllerWasInjected(self, in: notification) else { return }

    NotificationCenter.default.removeObserver(self)
    removeChildViewControllers()
    removeViewsAndLayers()
    viewDidLoad()
    view.subviews.forEach { view in
      view.layout()
      view.display()

      (view as? NSTableView)?.reloadData()
      (view as? NSCollectionView)?.reloadData()
    }
  }

  private func removeViewsAndLayers() {
    view.subviews.forEach {
      $0.removeConstraints($0.constraints)
      $0.removeFromSuperview()
    }

    if let sublayers = self.view.layer?.sublayers {
      sublayers.forEach { $0.removeFromSuperlayer() }
    }
  }

  private func removeChildViewControllers() {
    #if swift(>=4.2)
    children.forEach {
      $0.view.removeFromSuperview()
      $0.removeFromParent()
    }
    #else
    childViewControllers.forEach {
      $0.view.removeFromSuperview()
      $0.removeFromParentViewController()
    }
    #endif
  }

  @objc func injected(_ notification: Notification) {
    viewDidLoadIfNeeded(notification)
  }
}
