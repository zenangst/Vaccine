import XCTest
import Vaccine

class ViewControllerTests: XCTestCase {
  let utilities = Utilities()

  class ViewControllerMock: UIViewController {}

  class ParentViewControllerMock: UIViewController {
    lazy var dummyView = UIView()
    lazy var dummyLayer = CALayer()
    lazy var childViewController = ViewControllerMock()
    var timesInvoked: Int = 0

    override func viewDidLoad() {
      super.viewDidLoad()
      addInjection(with: #selector(injected(_:)))
      view.addSubview(dummyView)
      view.layer.addSublayer(dummyLayer)
      addChildViewController(childViewController)
      timesInvoked += 1
    }
  }

  func testSettingUpInjection() {
    let viewController = ParentViewControllerMock()
    viewController.addInjection(with: #selector(ViewControllerMock.injected(_:)))
    let _ = viewController.view
    XCTAssertEqual(viewController.timesInvoked, 1)
    utilities.triggerInjection(viewController)
    XCTAssertEqual(viewController.timesInvoked, 2)
    XCTAssertEqual(viewController.childViewControllers.count, 1)
    XCTAssertEqual(viewController.view.subviews.count, 1)
    XCTAssertEqual(viewController.view.layer.sublayers?.count, 2)
  }
}
