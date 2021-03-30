//
//  VGSFieldNameToJSONTests.swift
//  FrameworkTests
//
//  Created on 09.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation
import XCTest
@testable import VGSCollectSDK

/// Test fieldName dot notaion mapping.
class VGSFieldNameToJSONTests: XCTestCase {
	struct VGSFieldNameTestData {
		let fieldName: String
		let fieldValue: String
		let expectedResult: JsonData
		let comment: String

		init?(json: JsonData) {
			guard let fieldName = json["fieldName"] as? String,
						let fieldValue = json["fieldValue"] as? String,
						let expectedResult = json["expectedResult"] as? JsonData else {
				return nil
			}

			self.fieldName = fieldName
			self.fieldValue = fieldValue
			self.expectedResult = expectedResult
			self.comment = json["comment"] as? String ?? ""
		}
	}

	/// Test field name to JSON logic.
	func testFieldNameToJSON() {
		let testData = VGSFieldNameMapperTestDataProvider.provideTestDataForVGSFieldNameToJSON()

		for index in 0..<testData.count {
			let item = testData[index]
			let fieldName = item.fieldName
			let fieldValue = item.fieldValue
			let expectedResult = item.expectedResult
			let comment = item.comment

			var actualResultJSON: JsonData = [:]
			_ = VGSFieldNameToJSONDataMapper.mapFieldNameToJSON(fieldName, value: fieldValue, json: &actualResultJSON)

			let debugOutput = "index: \(index). \nFieldName *\(fieldName) should produce \(expectedResult), \n\ncomment: \(comment)* \n\nActual result: \(actualResultJSON)"

			XCTAssertTrue(actualResultJSON == expectedResult, debugOutput)
		}
	}
}

class VGSFieldNameMapperTestDataProvider {
	static func provideTestDataForVGSFieldNameToJSON() -> [VGSFieldNameToJSONTests.VGSFieldNameTestData] {
		guard let rootTestJSON = JsonData(jsonFileName: "VGSFieldNameToJSONTestData"), let testDataJSONArray = rootTestJSON["test_data"] as? [JsonData] else {
			XCTFail("cannot build data for file VGSFieldNameToJSONTestData")
			return []
		}

		var testData = [VGSFieldNameToJSONTests.VGSFieldNameTestData]()

		for json in testDataJSONArray {
			if let testItem = VGSFieldNameToJSONTests.VGSFieldNameTestData(json: json) {
				testData.append(testItem)
			} else {
				XCTFail("Cannot build test data for json: \(json)")
			}
		}

		return testData
	}
  
	static func provideTestDataForDeepMergeArrays() -> [VGSDeepMergeUtilsTests.TestJSONData] {
		return provideTestData(for: "DeepMergeMergeArrayTestJSONs")
	}

	static func provideTestDataForOverwriteArrays() -> [VGSDeepMergeUtilsTests.TestJSONData] {
		return provideTestData(for: "OverwriteArraysTestJSONs")
	}

	static func provideTestData(for fileName: String) -> [VGSDeepMergeUtilsTests.TestJSONData] {
		guard let rootTestJSON = JsonData(jsonFileName: fileName), let testDataJSONArray = rootTestJSON["test_data"] as? [JsonData] else {
			XCTFail("Cannot build data for file VGSDeepMergeUtilsTests.TestJSONData")
			return []
		}

		var testData = [VGSDeepMergeUtilsTests.TestJSONData]()

		for json in testDataJSONArray {
			if let testItem = VGSDeepMergeUtilsTests.TestJSONData(json: json) {
				testData.append(testItem)
			} else {
				XCTFail("Cannot build test data for json: \(json)")
			}
		}

		return testData
	}
}
