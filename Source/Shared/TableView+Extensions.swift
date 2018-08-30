#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public extension TableView {
  static func _swizzleTableViews() {
    #if DEBUG
    DispatchQueue.once(token: "com.zenangst.Vaccine.swizzleTableViews") {
      let originalSelector = #selector(setter: TableView.dataSource)
      let swizzledSelector = #selector(TableView.vaccine_setDataSource(_:))
      Swizzling.swizzle(TableView.self,
                        originalSelector: originalSelector,
                        swizzledSelector: swizzledSelector)
    }
    #endif
  }

  @objc func vaccine_setDataSource(_ dataSource: TableViewDataSource) {
    self.vaccine_setDataSource(dataSource)
    addInjection(with: #selector(vaccine_datasource_injected))
  }

  @objc func vaccine_datasource_injected(_ notification: Notification) {
    guard let dataSource = dataSource else { return }
    guard Injection.objectWasInjected(dataSource, in: notification) else { return }
    reloadData()
  }
}
