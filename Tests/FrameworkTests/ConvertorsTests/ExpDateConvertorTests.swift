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
  var textField: VGSExpDateTextField!
  typealias TestDataType = (input: String, output: String)

  override func setUp() {
      collector = VGSCollect(id: "any")
      textField = VGSExpDateTextField()
  }

  override func tearDown() {
      collector = nil
      textField = nil
  }
  
  func testConvertExpDateFormat() {
    let config = VGSExpDateConfiguration(collector: collector, fieldName: "textField")
    config.formatPattern = "##/####"
    config.divider = "/"
    config.inputDateFormat = .longYear
    config.outputDateFormat = .shortYear
    textField.configuration = config
   
    let testDates1: [TestDataType] = [("12/2021", "12/21"),
                                     ("01/2050", "01/50"),
                                     ("05/2100", "05/00")]
    
    for date in testDates1 {
			textField.textField.secureText = date.input
			if let outputText = textField.getOutputText() {
				XCTAssertTrue( outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
			} else {
				assertionFailure("outputText: \(textField.getOutputText())")
			}
    }
    
    config.inputDateFormat = .shortYear
    config.outputDateFormat = .longYear
    textField.configuration = config
   
    let testDates2: [TestDataType] = [("12/21", "12/2021"),
                                     ("01/50", "01/2050"),
                                     ("05/01", "05/2001")]
    
    for date in testDates2 {
      textField.textField.secureText = date.input
			if let outputText = textField.getOutputText() {
				XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
			} else {
				assertionFailure("outputText: \(textField.getOutputText())")
			}
    }
    
    config.divider = ""
    config.inputDateFormat = .longYear
    config.outputDateFormat = .shortYear
    textField.configuration = config
   
    let testDates3: [TestDataType] = [("122021", "1221"),
                                     ("012050", "0150"),
                                     ("052100", "0500")]
    
    for date in testDates3 {
      textField.textField.secureText = date.input
			if let outputText = textField.getOutputText() {
				XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
			} else {
				assertionFailure("outputText: \(textField.getOutputText())")
			}
    }
    
    config.divider = "-/-"
    config.inputDateFormat = .shortYear
    config.outputDateFormat = .longYear
    textField.configuration = config
   
    let testDates4: [TestDataType] = [("12-/-21", "12-/-2021"),
                                     ("01-/-50", "01-/-2050"),
                                     ("05-/-01", "05-/-2001")]
    
    for date in testDates4 {
			textField.textField.secureText = date.input
			if let outputText = textField.getOutputText() {
				XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
			} else {
				assertionFailure("outputText: \(textField.getOutputText())")
			}
    }
  }
}
