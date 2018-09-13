import XCTest
import Vaccine

class UIApplicationDelegateTests: XCTestCase {
  let utilities = Utilities()

  class ApplicationDelegateMock: NSObject, UIApplicationDelegate {
    var timesInvoked: Int = 0

    func loadInitialState() {
      timesInvoked += 1
    }

    @objc open func injected(_ notification: Notification) {
      timesInvoked += 1
    }
  }

  func testSettingUpInjection() {
    let applicationDelegate = ApplicationDelegateMock()
    Injection.load(then: applicationDelegate.loadInitialState)
    applicationDelegate.addInjection(with: #selector(ApplicationDelegateMock.injected(_:)))
    utilities.triggerInjection()
    XCTAssertEqual(applicationDelegate.timesInvoked, 1)
  }
}
