import XCTest
import Vaccine

class NSApplicationDelegateTests: XCTestCase {
  let utilities = Utilities()

  class ApplicationDelegateMock: NSObject, NSApplicationDelegate {
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
    applicationDelegate.loadInjection(applicationDelegate.loadInitialState)
    applicationDelegate.addInjection(with: #selector(ApplicationDelegateMock.injected(_:)))
    XCTAssertEqual(applicationDelegate.timesInvoked, 1)
    utilities.triggerInjection()
    XCTAssertEqual(applicationDelegate.timesInvoked, 2)
  }
}
