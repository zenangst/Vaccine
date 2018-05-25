import XCTest
import Vaccine

class NSObjectTests: XCTestCase {
  let utilities = Utilities()

  class MockedObject: NSObject {
    var injectionInvoked: Bool = false

    @objc open func injected(_ notification: Notification) {
      injectionInvoked = true
    }
  }

  func testInjectionSetup() {
    let object = MockedObject()
    object.addInjection(with: #selector(MockedObject.injected(_:)))
    utilities.triggerInjection()
    XCTAssertTrue(object.injectionInvoked)
  }
}
