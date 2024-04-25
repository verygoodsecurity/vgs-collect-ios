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
  
  func fillInCorrectFullDateWithDatePicker() {
    app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "May")
    app.pickerWheels.element(boundBy: 0).tap()
    
    app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "5")
    app.pickerWheels.element(boundBy: 1).tap()

    app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "2027")
    app.pickerWheels.element(boundBy: 2).tap()
  }

  /// Verifies success response exist.
  func verifySuccessResponse() {
    let successResponsePredicate = NSPredicate(format: "label BEGINSWITH 'Success: '")
    let successResponseLabel = app.staticTexts.element(matching: successResponsePredicate)
    XCTAssert(successResponseLabel.exists)
  }
  
  func verifyFormIsValid() {
    let validFormPredicate = NSPredicate(format: "label BEGINSWITH 'STATE: All Valid!'")
    let stateLabel = app.staticTexts.element(matching: validFormPredicate)
    XCTAssert(stateLabel.exists)
  }
}
