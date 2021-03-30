//
//  VGSExpDateSeparateSerializerTests.swift
//  FrameworkTests
//
//  Created by Dima on 27.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation
import XCTest
@testable import VGSCollectSDK

class VGSExpDateSeparateSerializerTests: VGSCollectBaseTestCase {
  var collector: VGSCollect!
  var textField: VGSExpDateTextField!

	enum TestFlow {
		case defaultConfiguration
		case customConfiguration
		case mapWithArrayOverwrite
		case mapWithArrayMerge

		var jsonFileName: String {
			return "VGSExpDateSerialization_" + jsonFileNameSuffix
		}

		var jsonFileNameSuffix: String {
			switch self {
			case .defaultConfiguration:
				return "DefaultConfig"
			case .customConfiguration:
				return "CustomConfig"
			case .mapWithArrayOverwrite:
				return "MapWithArrayOverwrite"
			case .mapWithArrayMerge:
				return "MapWithArrayMerge"
			}
		}
	}

  struct TestJSONData {
    let fieldValue: String
    let monthFieldName: String
    let yearFieldName: String
    let submitJSON: JsonData
    
    init?(json: JsonData) {
      guard let submitJSON = json["expectedResult"] as? JsonData else {
        XCTFail("Cannot parse test data.")
        return nil
      }
      self.fieldValue = json["fieldValue"] as? String ?? ""
      self.monthFieldName = json["monthFieldName"] as? String ?? ""
      self.yearFieldName = json["yearFieldName"] as? String ?? ""
      self.submitJSON = submitJSON
    }
  }

	// MARK: - Override

  override func setUp() {
      super.setUp()
      collector = VGSCollect(id: "any")
      textField = VGSExpDateTextField()
  }

  override func tearDown() {
      collector = nil
      textField = nil
  }

	// MARK: - Tests

	/// Test default configuration.
  func testSplitExpDateSerializerWithDefaultConfig() {
		let fileName = TestFlow.defaultConfiguration.jsonFileName
		let testData = VGSExpDateSerializersDataProvider.provideTestData(for: fileName)
    
    let config = VGSExpDateConfiguration(collector: collector, fieldName: "expDate")
    config.formatPattern = "##/##"
    
    for test in testData {
      config.serializers = [VGSExpDateSeparateSerializer(monthFieldName: test.monthFieldName, yearFieldName: test.yearFieldName)]
      textField.configuration = config
      textField.setText(test.fieldValue)
      
      let submitJSON = collector.mapFieldsToBodyJSON(with: .nestedJSON, extraData: nil)
      XCTAssertTrue(submitJSON == test.submitJSON, "Expiration date convert error:\n - Input: \(test.fieldValue)\n - Output: \(test.submitJSON)\n - Result: \(submitJSON)")
    }
  }

	/// Test custom exp date configuration.
  func testSplitExpDateSerializerWithCustomConfig() {
		let fileName = TestFlow.customConfiguration.jsonFileName
		let testData = VGSExpDateSerializersDataProvider.provideTestData(for: fileName)
    
    let config = VGSExpDateConfiguration(collector: collector, fieldName: "card.expDate")
    config.formatPattern = "##/##"
    config.inputDateFormat = .shortYear
    config.outputDateFormat = .longYear
    config.divider = "-/-"
    
    for test in testData {
      config.serializers = [VGSExpDateSeparateSerializer(monthFieldName: test.monthFieldName, yearFieldName: test.yearFieldName)]
      textField.configuration = config
      textField.setText(test.fieldValue)
      
      let submitJSON = collector.mapFieldsToBodyJSON(with: .nestedJSON, extraData: nil)
      XCTAssertTrue(submitJSON == test.submitJSON, "Expiration date convert error:\n - Input: \(test.fieldValue)\n - Output: \(test.submitJSON)\n - Result: \(submitJSON)")
      
    }
  }

	/// Test map with array merge.
	func testSplitExpDateSerializersMapWithArray() {
		let fileName = TestFlow.mapWithArrayMerge.jsonFileName
		let testData = VGSExpDateSerializersDataProvider.provideTestData(for: fileName)

		let config = VGSExpDateConfiguration(collector: collector, fieldName: "expDate")
		config.formatPattern = "##/##"

		let extraData = ["card_data":
											[
												["user_id": "123"]
											]]

		for test in testData {
			config.serializers = [VGSExpDateSeparateSerializer(monthFieldName: test.monthFieldName, yearFieldName: test.yearFieldName)]
			textField.configuration = config
			textField.setText(test.fieldValue)

			let submitJSON = collector.mapFieldsToBodyJSON(with: .nestedJSONWithArrayMerge, extraData: extraData)
			XCTAssertTrue(submitJSON == test.submitJSON, "Expiration date convert error:\n - Input: \(test.fieldValue)\n - Output: \(test.submitJSON)\n - Result: \(submitJSON)")
		}
	}

	/// Test map with array overwrite.
	func testSplitExpDateSerializersMapWithArrayOverwrite() {
		let fileName = TestFlow.mapWithArrayOverwrite.jsonFileName
		let testData = VGSExpDateSerializersDataProvider.provideTestData(for: fileName)

		let config = VGSExpDateConfiguration(collector: collector, fieldName: "expDate")
		config.formatPattern = "##/##"

		let extraData = ["card_data":
											[
												["month": "3",
												"year": "2033"]
											]]

		for test in testData {
			config.serializers = [VGSExpDateSeparateSerializer(monthFieldName: test.monthFieldName, yearFieldName: test.yearFieldName)]
			textField.configuration = config
			textField.setText(test.fieldValue)

			let submitJSON = collector.mapFieldsToBodyJSON(with: .nestedJSONWithArrayOverwrite, extraData: extraData)
			XCTAssertTrue(submitJSON == test.submitJSON, "Expiration date convert error:\n - Input: \(test.fieldValue)\n - Output: \(test.submitJSON)\n - Result: \(submitJSON)")
		}
	}
}
