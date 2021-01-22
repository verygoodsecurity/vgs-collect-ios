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
    config.inputDateFormat = "MM/yyyy"
    config.outputDateFormat = "MM/yy"
    textField.configuration = config
   
    let testDates1: [TestDataType] = [("12/2021", "12/21"),
                                     ("01/2050", "01/50"),
                                     ("05/2100", "05/00")]
    
    for date in testDates1 {
      textField.textField.secureText = date.input
      XCTAssertTrue(textField.getOutputText() == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(textField.getOutputText())")
    }
    
    config.inputDateFormat = "MM/yy"
    config.outputDateFormat = "MM/yyyy"
    textField.configuration = config
   
    let testDates2: [TestDataType] = [("12/21", "12/2021"),
                                     ("01/50", "01/2050"),
                                     ("05/00", "05/2000")]
    
    for date in testDates2 {
      textField.textField.secureText = date.input
      XCTAssertTrue(textField.getOutputText() == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(textField.getOutputText())")
    }
  }
}
