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
		app.launch()

		fillInTestData()
	}

	override func tearDownWithError() throws {
			// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func fillInTestData() {
		app.navigationBars["Demo"].buttons["VaultID"].tap()
		app.alerts["Set <vault id>"].waitForExistence(timeout: 3)
		app.alerts["Set <vault id>"].otherElements.collectionViews/*@START_MENU_TOKEN@*/.buttons["Clear text"]/*[[".cells",".textFields.buttons[\"Clear text\"]",".buttons[\"Clear text\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()


		app.alerts["Set <vault id>"].typeText("tntva5wfdrp")
		app.alerts["Set <vault id>"].otherElements.buttons["Save"].tap()
	}
}
