#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public extension CollectionView {
  static func _swizzleCollectionViews() {
    #if DEBUG
    DispatchQueue.once(token: "com.zenangst.Vaccine.\(#function)") {
      let originalSelector = #selector(setter: CollectionView.dataSource)
      let swizzledSelector = #selector(CollectionView.vaccine_setDataSource(_:))
      Swizzling.swizzle(CollectionView.self,
                        originalSelector: originalSelector,
                        swizzledSelector: swizzledSelector)
    }
    #endif
  }

  @objc func vaccine_setDataSource(_ newDataSource: CollectionViewDataSource?) {
    if dataSource == nil && newDataSource != nil {
      addInjection(with: #selector(vaccine_datasource_injected))
    }
    self.vaccine_setDataSource(newDataSource)
  }

  @objc func vaccine_datasource_injected(_ notification: Notification) {
    guard window != nil, let dataSource = dataSource else { return }
    guard Injection.objectWasInjected(dataSource, in: notification) else { return }
    reloadData()
  }
}
