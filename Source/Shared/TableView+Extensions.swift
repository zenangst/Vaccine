#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public extension TableView {
  static func _swizzleTableViews() {
    #if DEBUG
    DispatchQueue.once(token: "com.zenangst.Vaccine.\(#function)") {
      let originalSelector = #selector(setter: TableView.dataSource)
      let swizzledSelector = #selector(TableView.vaccine_setDataSource(_:))
      Swizzling.swizzle(TableView.self,
                        originalSelector: originalSelector,
                        swizzledSelector: swizzledSelector)
    }
    #endif
  }

  @objc func vaccine_setDataSource(_ newDataSource: TableViewDataSource?) {
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
