//
//  ExpDateConvertorTests.swift
//  FrameworkTests
//
//  Created by Dima on 22.01.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation
import XCTest
@testable import VGSCollectSDK

class ExpDateConvertorTests: VGSCollectBaseTestCase {
  var collector: VGSCollect!
  var textField: VGSExpDateTextField!

	struct TestDataType {
		let input: String
		let output: String
	}

  override func setUp() {
		  super.setUp()
      collector = VGSCollect(id: "any")
      textField = VGSExpDateTextField()
  }

  override func tearDown() {
      collector = nil
      textField = nil
  }

	func testConvertExpDate1() {
		let config = VGSExpDateConfiguration(collector: collector, fieldName: "textField")
		config.formatPattern = "##/####"
		config.divider = "/"
		config.inputDateFormat = .longYear
		config.outputDateFormat = .shortYear
		textField.configuration = config

		let testDates1: [TestDataType] = [TestDataType(input: "12/2021", output: "12/21"),
																			TestDataType(input: "01/2050", output: "01/50"),
																			TestDataType(input: "05/2100", output: "05/00")]

		for date in testDates1 {
			textField.setText(date.input)
			if let outputText = textField.getOutputText() {
				XCTAssertTrue( outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
			} else {
				print("failed: \(date.input) \(date.output)")
			}
		}
	}

	func testConvertExpDate2() {
		let config = VGSExpDateConfiguration(collector: collector, fieldName: "textField")

		config.formatPattern = "##/##"
		config.divider = "/"
		config.inputDateFormat = .shortYear
		config.outputDateFormat = .longYear
		textField.configuration = config

		let testDates2: [TestDataType] = [TestDataType(input: "12/21", output: "12/2021"),
																			TestDataType(input: "01/30", output: "01/2030"),
																			TestDataType(input: "05/01", output: "05/2001")]

		for date in testDates2 {
			textField.setText(date.input)
			if let outputText = textField.getOutputText() {
				XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
			} else {
				print("failed: \(date.input) \(date.output)")
			}
		}
	}

	func testConvertExpDate3() {
		let config = VGSExpDateConfiguration(collector: collector, fieldName: "textField")

		config.formatPattern = "##/####"
		config.divider = ""
		config.inputDateFormat = .longYear
		config.outputDateFormat = .shortYear
		textField.configuration = config

		let testDates3: [TestDataType] = [TestDataType(input: "122021", output: "1221"),
																			TestDataType(input: "012050", output: "0150"),
																			TestDataType(input: "052100", output: "0500")]

		for date in testDates3 {
			textField.setText(date.input)
			if let outputText = textField.getOutputText() {
				XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
			} else {
				print("failed: \(date.input) \(date.output)")
			}
		}
	}
  
  func testConvertExpDate4() {
		let config = VGSExpDateConfiguration(collector: collector, fieldName: "textField")
    
    config.divider = "-/-"
    config.inputDateFormat = .shortYear
    config.outputDateFormat = .longYear
    textField.configuration = config

		let testDates4: [TestDataType] = [TestDataType(input: "12-/-21", output: "12-/-2021"),
																			TestDataType(input: "01-/-30", output: "01-/-2030"),
																			TestDataType(input: "05-/-01", output: "05-/-2001")]
    
    for date in testDates4 {
			textField.setText(date.input)
			if let outputText = textField.getOutputText() {
				XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
			} else {
				print("failed: \(date.input) \(date.output)")
			}
    }
  }
}
