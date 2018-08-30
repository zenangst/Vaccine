#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public extension CollectionView {
  static func _swizzleCollectionViews() {
    #if DEBUG
    DispatchQueue.once(token: "com.zenangst.Vaccine.swizzleCollectionViews") {
      let originalSelector = #selector(setter: CollectionView.dataSource)
      let swizzledSelector = #selector(CollectionView.vaccine_setDataSource(_:))
      Swizzling.swizzle(UICollectionView.self,
                        originalSelector: originalSelector,
                        swizzledSelector: swizzledSelector)
    }
    #endif
  }

  @objc func vaccine_setDataSource(_ dataSource: CollectionViewDataSource) {
    self.vaccine_setDataSource(dataSource)
    addInjection(with: #selector(vaccine_datasource_injected))
  }

  @objc func vaccine_datasource_injected(_ notification: Notification) {
    guard let dataSource = dataSource else { return }
    guard Injection.objectWasInjected(dataSource, in: notification) else { return }
    reloadData()
  }
}
