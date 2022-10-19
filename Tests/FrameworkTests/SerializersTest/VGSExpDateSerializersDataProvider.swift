//
//  VGSExpDateSerializersDataProvider.swift
//  FrameworkTests
//
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation
import XCTest
@testable import VGSCollectSDK

final class VGSExpDateSerializersDataProvider {

	static func provideTestData(for fileName: String) -> [VGSExpDateSeparateSerializerTests.TestJSONData] {
		guard let rootTestJSON = JsonData(jsonFileName: fileName) else {
			XCTFail("cannot build data for file \(fileName)")
			return []
		}

    guard let testDataJSONArray = rootTestJSON["test_data"] as? [JsonData] else {
      XCTFail("test_data JSON array not found in \(fileName)")
      return []
    }

		var testData = [VGSExpDateSeparateSerializerTests.TestJSONData]()

		for json in testDataJSONArray {
			if let testItem = VGSExpDateSeparateSerializerTests.TestJSONData(json: json) {
				testData.append(testItem)
			} else {
				XCTFail("Cannot build test data for json: \(json)")
			}
		}
		return testData
	}

  static func provideTokenizationTestData(for fileName: String) -> [VGSExpDateTokenizationSerializerTests.TestJSONData] {
    guard let rootTestJSON = JsonData(jsonFileName: fileName) else {
      XCTFail("cannot build data for file \(fileName)")
      return []
    }

    guard let testDataJSONArray = rootTestJSON["test_data"] as? [JsonData] else {
      XCTFail("test_data JSON array not found in \(fileName)")
      return []
    }

    var testData = [VGSExpDateTokenizationSerializerTests.TestJSONData]()

    for json in testDataJSONArray {
      if let testItem = VGSExpDateTokenizationSerializerTests.TestJSONData(json: json) {
        testData.append(testItem)
      } else {
        XCTFail("Cannot build test data for json: \(json)")
      }
    }
    return testData
  }
}
