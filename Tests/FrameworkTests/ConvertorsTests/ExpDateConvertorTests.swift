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

class ExpDateConvertorTests: XCTestCase {
  var collector: VGSCollect!

	struct TestDataType {
		let input: String
		let output: String
	}

  func testConvertExpDateFormat() {
		collector = VGSCollect(id: "tntva5wfdrp")
		print("start testConvertExpDateFormat...")
		let textField = VGSExpDateTextField()
		print("start testConvertExpDateFormat...")
    let config = VGSExpDateConfiguration(collector: collector, fieldName: "textField")
    config.formatPattern = "##/####"
    config.divider = "/"
    config.inputDateFormat = .longYear
    config.outputDateFormat = .shortYear
    textField.configuration = config

		print("start testConvertExpDateFormat...")
   
		let testDates1: [TestDataType] = [TestDataType(input: "12/2021", output: "12/21"),
																			TestDataType(input:"01/2050", output: "01/50"),
																			TestDataType(input: "05/2100", output:"05/00")]
    
    for date in testDates1 {
			textField.setText(date.input)
			if let outputText = textField.getOutputText() {
				print("outputText: \(outputText)")
				print("date.input: \(date.input)")
				print("date.output: \(date.output)")
				XCTAssertTrue( outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
			} else {
				print("failed: \(date.input) \(date.output)")
			}
    }

    config.inputDateFormat = .shortYear
    config.outputDateFormat = .longYear
    textField.configuration = config
   
		let testDates2: [TestDataType] = [TestDataType(input: "12/21", output: "12/2021"),
																			TestDataType(input: "01/50", output: "01/2050"),
																			TestDataType(input: "05/01", output: "05/2001")]
    
    for date in testDates2 {
			textField.setText(date.input)
			if let outputText = textField.getOutputText() {
				XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
			} else {
				print("failed: \(date.input) \(date.output)")
			}
    }

		return
    
    config.divider = ""
    config.inputDateFormat = .longYear
    config.outputDateFormat = .shortYear
    textField.configuration = config
   
		let testDates3: [TestDataType] = [TestDataType(input:"122021", output: "1221"),
																			TestDataType(input:"012050", output: "0150"),
																			TestDataType(input:"052100", output: "0500")]
    
    for date in testDates3 {
			textField.setText(date.input)
			if let outputText = textField.getOutputText() {
				XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
			} else {
				print("failed: \(date.input) \(date.output)")
			}
    }
    
    config.divider = "-/-"
    config.inputDateFormat = .shortYear
    config.outputDateFormat = .longYear
    textField.configuration = config
   
		let testDates4: [TestDataType] = [TestDataType(input:"12-/-21", output: "12-/-2021"),
																			TestDataType(input:"01-/-50", output: "01-/-2050"),
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
