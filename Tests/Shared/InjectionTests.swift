import XCTest
import Vaccine

class InjectionTests: XCTestCase {
  let utilities = Utilities()

  class MockedObject: NSObject {
    var injectionInvoked: Bool = false

    @objc open func injected(_ notification: Notification) {
      injectionInvoked = true
    }
  }

  func testInjectionSetup() {
    let object = MockedObject()

    Injection.load()
    Injection.add(observer: object, with: #selector(MockedObject.injected(_:)))
    utilities.triggerInjection()
    XCTAssertTrue(object.injectionInvoked)
    object.removeInjection()
  }
}
