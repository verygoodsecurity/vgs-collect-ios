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
}
