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
@MainActor
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
  
  func testConvertExpDate5() {
    let config = VGSExpDateConfiguration(collector: collector, fieldName: "textField")
    
    config.divider = "-/-"
    config.inputDateFormat = .shortYear
    config.outputDateFormat = .shortYearThenMonth
    textField.configuration = config

    let testDates5: [TestDataType] = [TestDataType(input: "12-/-21", output: "21-/-12"),
                                      TestDataType(input: "01-/-30", output: "30-/-01"),
                                      TestDataType(input: "05-/-01", output: "01-/-05")]
    
    for date in testDates5 {
      textField.setText(date.input)
      if let outputText = textField.getOutputText() {
        XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
      } else {
        print("failed: \(date.input) \(date.output)")
      }
    }
  }
  
  func testConvertExpDate6() {
    let config = VGSExpDateConfiguration(collector: collector, fieldName: "textField")
    
    config.divider = "../"
    config.inputDateFormat = .shortYear
    config.outputDateFormat = .longYearThenMonth
    textField.configuration = config

    let testDates6: [TestDataType] = [TestDataType(input: "12../21", output: "2021../12"),
                                      TestDataType(input: "01../30", output: "2030../01"),
                                      TestDataType(input: "05../21", output: "2021../05")]
    
    for date in testDates6 {
      textField.setText(date.input)
      if let outputText = textField.getOutputText() {
        XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
      } else {
        print("failed: \(date.input) \(date.output)")
      }
    }
  }
  
  func testConvertExpDate7() {
    let config = VGSExpDateConfiguration(collector: collector, fieldName: "textField")
    
    config.formatPattern = "##/####"
    config.inputDateFormat = .longYear
    config.outputDateFormat = .shortYearThenMonth
    textField.configuration = config

    let testDates7: [TestDataType] = [TestDataType(input: "122021", output: "21/12"),
                                      TestDataType(input: "012030", output: "30/01"),
                                      TestDataType(input: "052021", output: "21/05")]
    
    for date in testDates7 {
      textField.setText(date.input)
      if let outputText = textField.getOutputText() {
        XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
      } else {
        print("failed: \(date.input) \(date.output)")
      }
    }
  }
  
  func testConvertExpDate8() {
    let config = VGSExpDateConfiguration(collector: collector, fieldName: "textField")
    
    config.formatPattern = "##-####"
    config.inputDateFormat = .longYear
    config.outputDateFormat = .longYearThenMonth
    textField.configuration = config

    let testDates8: [TestDataType] = [TestDataType(input: "12 2021", output: "2021/12"),
                                      TestDataType(input: "01 2030", output: "2030/01"),
                                      TestDataType(input: "05 2021", output: "2021/05")]
    
    for date in testDates8 {
      textField.setText(date.input)
      if let outputText = textField.getOutputText() {
        XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
      } else {
        print("failed: \(date.input) \(date.output)")
      }
    }
  }
  
  func testConvertExpDate9() {
    let config = VGSExpDateConfiguration(collector: collector, fieldName: "textField")
    
    config.inputDateFormat = .shortYearThenMonth
    config.outputDateFormat = .longYearThenMonth
    textField.configuration = config

    let testDates9: [TestDataType] = [TestDataType(input: "2112", output: "2021/12"),
                                      TestDataType(input: "3001", output: "2030/01"),
                                      TestDataType(input: "2105", output: "2021/05")]
    
    for date in testDates9 {
      textField.setText(date.input)
      if let outputText = textField.getOutputText() {
        XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
      } else {
        print("failed: \(date.input) \(date.output)")
      }
    }
  }
  
  func testConvertExpDate10() {
    let config = VGSExpDateConfiguration(collector: collector, fieldName: "textField")
    
    config.formatPattern = "####---##"
    config.inputDateFormat = .longYearThenMonth
    config.outputDateFormat = .shortYearThenMonth
    textField.configuration = config

    let testDates10: [TestDataType] = [TestDataType(input: "202112", output: "21///12"),
                                      TestDataType(input: "203001", output: "30///01"),
                                      TestDataType(input: "202105", output: "21///05")]
    
    for date in testDates10 {
      textField.setText(date.input)
      if let outputText = textField.getOutputText() {
        XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
      } else {
        print("failed: \(date.input) \(date.output)")
      }
    }
  }
  
  func testConvertExpDate11() {
    let config = VGSExpDateConfiguration(collector: collector, fieldName: "textField")
    
    config.inputDateFormat = .shortYearThenMonth
    config.outputDateFormat = .shortYear
    textField.configuration = config

    let testDates11: [TestDataType] = [TestDataType(input: "21/12", output: "12/21"),
                                      TestDataType(input: "30/01", output: "01/30"),
                                      TestDataType(input: "21/05", output: "05/21")]
    
    for date in testDates11 {
      textField.setText(date.input)
      if let outputText = textField.getOutputText() {
        XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
      } else {
        print("failed: \(date.input) \(date.output)")
      }
    }
  }
  
  func testConvertExpDate12() {
    let config = VGSExpDateConfiguration(collector: collector, fieldName: "textField")
    
    config.formatPattern = "#### ##"
    config.divider = "."
    config.inputDateFormat = .longYearThenMonth
    config.outputDateFormat = .longYear
    textField.configuration = config

    let testDates11: [TestDataType] = [TestDataType(input: "202112", output: "12.2021"),
                                       TestDataType(input: "203001", output: "01.2030"),
                                       TestDataType(input: "202105", output: "05.2021")]
    
    for date in testDates11 {
      textField.setText(date.input)
      if let outputText = textField.getOutputText() {
        XCTAssertTrue(outputText == date.output, "Expiration date convert error:\n - Input: \(date.input)\n - Output: \(date.output)\n - Result: \(outputText)")
      } else {
        print("failed: \(date.input) \(date.output)")
      }
    }
  }
}
