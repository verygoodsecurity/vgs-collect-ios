//
//  VGSDeepMergeUtilsTests.swift
//  FrameworkTests
//
//  Created on 09.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation
import XCTest
@testable import VGSCollectSDK

class VGSDeepMergeUtilsTests: XCTestCase {

	struct TestFieldData {
		let fieldName: String
		let value: String

		init?(json: JsonData) {
			guard let name = json["fieldName"] as? String,
						let value = json["fieldValue"] as? String else {
				return nil
			}

			self.fieldName = name
			self.value = value
		}
	}

	struct TestJSONData {
		let fieldsData: [TestFieldData]
		let expectedCollectJSON: JsonData
		let extraData: JsonData?
		let expectedSubmitJSON: JsonData
		let comment: String?

		init?(json: JsonData) {
			guard let jsonFieldsData = json["fieldsData"] as? [JsonData] else {
				return nil
			}

			fieldsData = jsonFieldsData.compactMap({ json -> TestFieldData? in
				let fieldJson = TestFieldData(json: json)
				if fieldJson == nil {
					XCTFail("Cannot parse fields JSON.")
				}

				return fieldJson
			})

			guard let expectedCollectJSON = json["expectedCollectJSON"] as? JsonData, let submitJSON = json["expectedSubmitJSON"] as? JsonData else {
				XCTFail("Cannot parse test data.")
				return nil
			}

			self.expectedCollectJSON = expectedCollectJSON
			self.expectedSubmitJSON = submitJSON

			self.extraData = json["etraData"] as? JsonData ?? nil
			self.comment = json["comment"] as? String ?? nil
		}
	}

	/// Test deep merge JSON arrays.
	func testDeepMergeJSONOArrays() {
		let testData = VGSFieldNameMapperTestDataProvider.provideTestDataForDeepMergeArrays()

		for index in 0..<testData.count {
			let item = testData[index]
			let fieldData = item.fieldsData
			let expectedCollectJSON = item.expectedCollectJSON
			let extraData = item.extraData
			let expectedSubmitJSON = item.expectedSubmitJSON
			let comment = item.comment ?? ""

			var textFields = [VGSTextField]()

			for fieldItem in fieldData {
				let field = VGSTextField()
				field.fieldName = fieldItem.fieldName
				field.textField.secureText = fieldItem.value

				textFields.append(field)
			}

			let actualCollectJSON: JsonData = VGSFieldNameToJSONDataMapper.provideJSON(for: textFields)

			print("actualJSON: \(actualCollectJSON)")

			let debugFieldsOutput = "index: \(index). \nFielsdData *\(fieldData) should produce \(expectedCollectJSON), \n\ncomment: \(comment)* \n\nActual result: \(actualCollectJSON)"

			XCTAssertTrue(actualCollectJSON == expectedCollectJSON, debugFieldsOutput)

			let actualJSONToSubmit: JsonData = VGSCollect.mapStoredInputDataForSubmitWithArrays(fields: textFields, mergeArrayPolicy: .merge, extraData: extraData)

			let debugDeepMergeOutput = "index: \(index). \nFielsdData *\(fieldData) \nExtra data: \(extraData) \nshould produce \(expectedSubmitJSON), \n\ncomment: \(comment)* \n\nActual result: \(actualJSONToSubmit)"

			XCTAssertTrue(actualJSONToSubmit == expectedSubmitJSON, debugDeepMergeOutput)
		}
	}

	/// Test overwrite JSON arrays.
	func testOverwriteJSONOArrays() {
		let testData = VGSFieldNameMapperTestDataProvider.provideTestDataForOverwriteArrays()

		for index in 0..<testData.count {
			let item = testData[index]
			let fieldData = item.fieldsData
			let expectedCollectJSON = item.expectedCollectJSON
			let extraData = item.extraData
			let expectedSubmitJSON = item.expectedSubmitJSON
			let comment = item.comment ?? ""

			var textFields = [VGSTextField]()

			for fieldItem in fieldData {
				let field = VGSTextField()
				field.fieldName = fieldItem.fieldName
				field.textField.secureText = fieldItem.value

				textFields.append(field)
			}

			let actualCollectJSON: JsonData = VGSFieldNameToJSONDataMapper.provideJSON(for: textFields)

			print("actualJSON: \(actualCollectJSON)")

			let debugFieldsOutput = "index: \(index). \nFielsdData *\(fieldData) should produce \(expectedCollectJSON), \n\ncomment: \(comment)* \n\nActual result: \(actualCollectJSON)"

			XCTAssertTrue(actualCollectJSON == expectedCollectJSON, debugFieldsOutput)

			let actualJSONToSubmit: JsonData = VGSCollect.mapStoredInputDataForSubmitWithArrays(fields: textFields, mergeArrayPolicy: .overwrite, extraData: extraData)

			let debugDeepMergeOutput = "index: \(index). \nFielsdData *\(fieldData) \nExtra data: \(extraData) \nshould produce \(expectedSubmitJSON), \n\ncomment: \(comment)* \n\nActual result: \(actualJSONToSubmit)"

			XCTAssertTrue(actualJSONToSubmit == expectedSubmitJSON, debugDeepMergeOutput)
		}
	}
}
