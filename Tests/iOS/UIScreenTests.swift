import XCTest
import Vaccine

class UIScreenTests: XCTestCase {
  let screenBounds = UIScreen.main.bounds

  func testIPhone8WithoutOrientation() {
    let result = UIScreen.device(.iPhone8(orientation: nil))
    let expectedSize = CGSize(width: 375, height: 667)
    let expectedResult = CGRect(
      origin: CGPoint(x: screenBounds.size.width / 2 - expectedSize.width / 2,
                      y: screenBounds.size.height / 2 - expectedSize.height / 2),
      size: expectedSize
    )
    XCTAssertEqual(result, expectedResult)
  }

  func testIPhone4Portrait() {
    let result = UIScreen.device(.iPhone4(orientation: .portrait))
    let expectedSize = CGSize(width: 240, height: 320)
    let expectedResult = CGRect(
      origin: CGPoint(x: screenBounds.size.width / 2 - expectedSize.width / 2,
                      y: screenBounds.size.height / 2 - expectedSize.height / 2),
      size: expectedSize
    )
    XCTAssertEqual(result, expectedResult)
  }

  func testIPhoneSEPortrait() {
    let result = UIScreen.device(.iPhoneSE(orientation: .portrait))
    let expectedSize = CGSize(width: 320, height: 568)
    let expectedResult = CGRect(
      origin: CGPoint(x: screenBounds.size.width / 2 - expectedSize.width / 2,
                      y: screenBounds.size.height / 2 - expectedSize.height / 2),
      size: expectedSize
    )
    XCTAssertEqual(result, expectedResult)
  }

  func testIPhone8Portrait() {
    let result = UIScreen.device(.iPhone8(orientation: .portrait))
    let expectedSize = CGSize(width: 375, height: 667)
    let expectedResult = CGRect(
      origin: CGPoint(x: screenBounds.size.width / 2 - expectedSize.width / 2,
                      y: screenBounds.size.height / 2 - expectedSize.height / 2),
      size: expectedSize
    )
    XCTAssertEqual(result, expectedResult)
  }

  func testIPhone8PlusPortrait() {
    let result = UIScreen.device(.iPhone8Plus(orientation: .portrait))
    let expectedSize = CGSize(width: 414, height: 736)
    let expectedResult = CGRect(
      origin: CGPoint(x: screenBounds.size.width / 2 - expectedSize.width / 2,
                      y: screenBounds.size.height / 2 - expectedSize.height / 2),
      size: expectedSize
    )
    XCTAssertEqual(result, expectedResult)
  }

  func testIPhoneXPortrait() {
    let result = UIScreen.device(.iPhoneX(orientation: .portrait))
    let expectedSize = CGSize(width: 375, height: 812)
    let expectedResult = CGRect(
      origin: CGPoint(x: screenBounds.size.width / 2 - expectedSize.width / 2,
                      y: screenBounds.size.height / 2 - expectedSize.height / 2),
      size: expectedSize
    )
    XCTAssertEqual(result, expectedResult)
  }

  func testIPadPortrait() {
    let result = UIScreen.device(.iPad(orientation: .portrait))
    let expectedSize = CGSize(width: 768, height: 1024)
    let expectedResult = CGRect(
      origin: CGPoint(x: screenBounds.size.width / 2 - expectedSize.width / 2,
                      y: screenBounds.size.height / 2 - expectedSize.height / 2),
      size: expectedSize
    )
    XCTAssertEqual(result, expectedResult)
  }

  func testIPhone4Landscape() {
    let result = UIScreen.device(.iPhone4(orientation: .landscape))
    let expectedSize = CGSize(width: 320, height: 240)
    let expectedResult = CGRect(
      origin: CGPoint(x: screenBounds.size.width / 2 - expectedSize.width / 2,
                      y: screenBounds.size.height / 2 - expectedSize.height / 2),
      size: expectedSize
    )
    XCTAssertEqual(result, expectedResult)
  }

  func testIPhoneSELandscape() {
    let result = UIScreen.device(.iPhoneSE(orientation: .landscape))
    let expectedSize = CGSize(width: 568, height: 320)
    let expectedResult = CGRect(
      origin: CGPoint(x: screenBounds.size.width / 2 - expectedSize.width / 2,
                      y: screenBounds.size.height / 2 - expectedSize.height / 2),
      size: expectedSize
    )
    XCTAssertEqual(result, expectedResult)
  }

  func testIPhone8Landscape() {
    let result = UIScreen.device(.iPhone8(orientation: .landscape))
    let expectedSize = CGSize(width: 667, height: 375)
    let expectedResult = CGRect(
      origin: CGPoint(x: screenBounds.size.width / 2 - expectedSize.width / 2,
                      y: screenBounds.size.height / 2 - expectedSize.height / 2),
      size: expectedSize
    )
    XCTAssertEqual(result, expectedResult)
  }

  func testIPhone8PlusLandscape() {
    let result = UIScreen.device(.iPhone8Plus(orientation: .landscape))
    let expectedSize = CGSize(width: 736, height: 414)
    let expectedResult = CGRect(
      origin: CGPoint(x: screenBounds.size.width / 2 - expectedSize.width / 2,
                      y: screenBounds.size.height / 2 - expectedSize.height / 2),
      size: expectedSize
    )
    XCTAssertEqual(result, expectedResult)
  }

  func testIPhoneXLandscape() {
    let result = UIScreen.device(.iPhoneX(orientation: .landscape))
    let expectedSize = CGSize(width: 812, height: 375)
    let expectedResult = CGRect(
      origin: CGPoint(x: screenBounds.size.width / 2 - expectedSize.width / 2,
                      y: screenBounds.size.height / 2 - expectedSize.height / 2),
      size: expectedSize
    )
    XCTAssertEqual(result, expectedResult)
  }

  func testIPadLandscape() {
    let result = UIScreen.device(.iPad(orientation: .landscape))
    let expectedSize = CGSize(width: 1024, height: 768)
    let expectedResult = CGRect(
      origin: CGPoint(x: screenBounds.size.width / 2 - expectedSize.width / 2,
                      y: screenBounds.size.height / 2 - expectedSize.height / 2),
      size: expectedSize
    )
    XCTAssertEqual(result, expectedResult)
  }
}
