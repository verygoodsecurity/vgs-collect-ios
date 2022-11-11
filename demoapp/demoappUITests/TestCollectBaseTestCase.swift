//
//  TestCollectBaseTestCase.swift
//  demoappUITests
//

import Foundation
import XCTest
@testable import demoapp

class TestCollectBaseTestCase: XCTestCase {

	var app: XCUIApplication!

	override func setUp() {
		super.setUp()

		continueAfterFailure = false

		app = XCUIApplication()
		app.launchArguments.append("VGSCollectDemoAppUITests")
		app.launch()

		fillInTestData()
	}

	override func tearDownWithError() throws {
			// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func fillInTestData() {
		wait(forTimeInterval: 0.3)
	}

  func fillInCorrectDateWithDatePicker() {
    app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "March")
    app.pickerWheels.element(boundBy: 0).tap()

    app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "2027")
    app.pickerWheels.element(boundBy: 1).tap()
  }
}
