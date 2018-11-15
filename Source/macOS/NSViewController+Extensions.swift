import Cocoa

@objc public extension NSViewController {
  /// Validate if the current class was injected by checking the contents
  /// of the notification.
  ///
  /// - Parameter notification: A standard InjectionIII notification
  private func viewDidLoadIfNeeded(_ notification: Notification) {
    guard Injection.isLoaded else { return }
    guard Injection.viewControllerWasInjected(self, in: notification) else { return }

    if !children.isEmpty && parent == nil {
      let snapshot = createSnapshot()
      self.view.window?.contentView?.addSubview(snapshot)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
        self?.performInjection(snapshot)
      }
    } else {
      performInjection()
    }
  }

  /// Invoke all injection related methods in sequence.
  /// If this method is invoked with animations enabled,
  /// a snapshot of the current view will be created and
  /// added to the applications window in order to nicely
  /// transition to the new controller view state.
  private func performInjection(_ snapshot: NSImageView? = nil) {
    guard !(self is NSCollectionViewItem) else {
      reloadCollectionViewItem()
      return
    }

    if Injection.animations {
      let currentSnapshot = snapshot ?? createSnapshot()
      let oldScrollViews = indexScrollViews()
      resetViewControllerState()
      rebuildViewContorllerState()
      self.view.window?.contentView?.addSubview(currentSnapshot)
      syncOldScrollViews(oldScrollViews, with: indexScrollViews())
      NSAnimationContext.runAnimationGroup({ (context) in
        context.allowsImplicitAnimation = true
        context.duration = 0.25
        currentSnapshot.animator().alphaValue = 0.0
      }, completionHandler: {
        currentSnapshot.removeFromSuperview()
      })
    } else {
      let scrollViews = indexScrollViews()
      lockScreenUpdates(!scrollViews.isEmpty)
      resetViewControllerState()
      rebuildViewContorllerState()
      unlockScreenUpdates(!scrollViews.isEmpty, scrollViews: scrollViews)
    }
  }

  private func reloadCollectionViewItem() {
    if Injection.animations {

      NSAnimationContext.runAnimationGroup({ (context) in
        context.allowsImplicitAnimation = true
        context.duration = 0.25
        resetViewControllerState()
        rebuildViewContorllerState()
      }, completionHandler: {})
    } else {
      lockScreenUpdates(true)
      resetViewControllerState()
      rebuildViewContorllerState()
      unlockScreenUpdates(true, scrollViews: [])
    }
  }

  /// Will invoke `viewDidLoad` to run view controllers setup operations.
  /// In addition, it will force all subview to layout and collection & table views
  /// to reload. This is to make sure that we are displaying the latest changes.
  private func rebuildViewContorllerState() {
    viewDidLoad()
    view.subviews.forEach { view in
      view.needsLayout = true
      view.needsDisplay = true

      (view as? NSTableView)?.reloadData()
      (view as? NSCollectionView)?.reloadData()
    }
    viewWillAppear()
    viewDidAppear()
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
  private func unlockScreenUpdates(_ shouldUnlock: Bool, scrollViews: [NSScrollView]) {
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
  private func indexScrollViews() -> [NSScrollView] {
    var scrollViews = [NSScrollView]()
    for case let scrollView as NSScrollView in view.subviews {
      scrollViews.append(scrollView)
    }

    if let parentViewController = parent {
      for case let scrollView as NSScrollView in parentViewController.view.subviews {
        scrollViews.append(scrollView)
      }
    }

    for childViewController in children {
      for case let scrollView as NSScrollView in childViewController.view.subviews {
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
  private func syncOldScrollViews(_ oldScrollViews: [NSScrollView], with newScrollViews: [NSScrollView]) {
    for (offset, scrollView) in newScrollViews.enumerated() {
      if offset < oldScrollViews.count {
        let oldScrollView = oldScrollViews[offset]
        if type(of: scrollView) == type(of: oldScrollView) {
          scrollView.contentView.scroll(to: oldScrollView.documentVisibleRect.origin)
        }
      }
    }
  }

  /// Removes all child view controllers.
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

  private func createSnapshot() -> NSImageView {
    let snapshot = NSImageView()
    snapshot.image = view.snapshot
    snapshot.frame.size = self.view.frame.size
    return snapshot
  }

  /// Clean up view hierarchy by removing child view controllers, view and layers.
  private func resetViewControllerState() {
    removeChildViewControllers()
    removeViewsAndLayers()
  }

  /// Removes all views and layers from a view.
  private func removeViewsAndLayers() {
    view.subviews.forEach {
      $0.removeFromSuperview()
    }

    if let sublayers = self.view.layer?.sublayers {
      sublayers.forEach { $0.removeFromSuperlayer() }
    }
  }

  @objc func injected(_ notification: Notification) {
    viewDidLoadIfNeeded(notification)
  }
}

fileprivate extension NSView {
  var snapshot: NSImage {
    guard let bitmapRep = bitmapImageRepForCachingDisplay(in: bounds) else { return NSImage() }
    cacheDisplay(in: bounds, to: bitmapRep)
    let image = NSImage()
    image.addRepresentation(bitmapRep)
    bitmapRep.size = bounds.size.doubleScale()
    return image
  }
}

fileprivate extension CGSize {
  func doubleScale() -> CGSize {
    return CGSize(width: width * 2, height: height * 2)
  }
}
