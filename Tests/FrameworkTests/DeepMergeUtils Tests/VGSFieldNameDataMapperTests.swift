//
//  VGSFieldNameDataMapperTests.swift
//  FrameworkTests
//
//  Created on 09.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation
import XCTest
@testable import VGSCollectSDK

class VGSFieldNameDataMapperTests: XCTestCase {

	/// Test deep merge for JSONs (without arrays).
	func testDeepMergeJSONs() {
		let cardNumberValue = "4111-1111-1111-1111"
		let fieldName = "card_data.number"

		let extraData: JsonData = [
				"card_data":
					[
							"number": "3714-4963-5398-431"
					]
		]

		let validResult: JsonData = [
			"card_data":
				 [
						 "number": "4111-1111-1111-1111"
				 ]
	 ]

		let vgsJSON = VGSFieldNameToJSONDataMapper.mapFieldNameToJSON(fieldName, value: cardNumberValue)

		print("vgsJSON: \(vgsJSON)")
		let dataToSubmit = VGSDeepMergeUtils.deepMerge(target: extraData, source: vgsJSON, deepMergeArray: true)
		print("dataToSubmit: \(dataToSubmit)")

		let resultKeys = dataToSubmit.keys
		XCTAssertTrue(resultKeys == validResult.keys, "result keys: \(resultKeys) should match keys: \(validResult.keys)")

		XCTAssertTrue(dataToSubmit == validResult, "result: \(dataToSubmit) should match validResult: \(validResult)")
	}

	/// Test deep merge for JSONs (without arrays and matching keys).
	func testDeepMergeJSONsAndMatchingKeys() {
		let cardNumberValue = "4111-1111-1111-1111"
		let fieldName = "card_data.number"

		let extraData: JsonData = [
				"card_data":
					[
							"cvc": "123"
					]
		]

		let validResult: JsonData = [
			"card_data":
				 [
						 "cvc": "123",
						 "number": "4111-1111-1111-1111"
				 ]
	 ]

		let vgsJSON = VGSFieldNameToJSONDataMapper.mapFieldNameToJSON(fieldName, value: cardNumberValue)

		print("vgsJSON: \(vgsJSON)")
		let dataToSubmit = VGSDeepMergeUtils.deepMerge(target: extraData, source: vgsJSON, deepMergeArray: true)
		print("dataToSubmit: \(dataToSubmit)")

		let resultKeys = dataToSubmit.keys
		XCTAssertTrue(resultKeys == validResult.keys, "result keys: \(resultKeys) should match keys: \(validResult.keys)")

		XCTAssertTrue(dataToSubmit == validResult, "result: \(dataToSubmit) should match validResult: \(validResult)")
	}


	/// Test deep merge without deep merging arrays with values.
	func testJoinValueArrays() {

    let cardNumberValue = "4111-1111-1111-1111"
		let fieldName = "data.card_data[1]"

		let extraData: JsonData = [
			"data":

				["card_data":
				 [
					"3714-4963-5398-431",

					"5555"
				 ]
			 ]
		 ]

		let validResult: JsonData = [
			"data":

				["card_data":
				 [

					"3714-4963-5398-431",

					"5555",

					nil,

					"4111-1111-1111-1111"
				 ]
			 ]
		 ]

		let vgsJSON = VGSFieldNameToJSONDataMapper.mapFieldNameToJSON(fieldName, value: cardNumberValue)

		print("vgsJSON: \(vgsJSON)")
		let dataToSubmit = VGSDeepMergeUtils.deepMerge(target: extraData, source: vgsJSON)
		print("dataToSubmit: \(dataToSubmit)")

		let resultKeys = dataToSubmit.keys
		XCTAssertTrue(resultKeys == validResult.keys, "result keys: \(resultKeys) should match keys: \(validResult.keys)")

		for (key, value) in dataToSubmit {

		}

		XCTAssertTrue(dataToSubmit == validResult, "result: \(dataToSubmit) should match validResult: \(validResult)")
	}

	/// Test deep merge without deep merging arrays with JSON.
	func testJoinJONArrays() {

		let cardNumberValue = "4111-1111-1111-1111"
		let fieldName = "card_data[0].number"

		let extraData: JsonData = [

				"card_data":
					[
						[
						  "number": "3714-4963-5398-431",

							"cvv": 123
				    ]
					]
		]

		let validResult: JsonData = [
			 "card_data":
				[
					[
						"number": "3714-4963-5398-431",

						"cvv": 123
					],
					[
						"number": "4111-1111-1111-1111"
					]
				]
		]

		let vgsJSON = VGSFieldNameToJSONDataMapper.mapFieldNameToJSON(fieldName, value: cardNumberValue)

		print("vgsJSON: \(vgsJSON)")
		let dataToSubmit = VGSDeepMergeUtils.deepMerge(target: extraData, source: vgsJSON)
		print("dataToSubmit: \(dataToSubmit)")

		let resultKeys = dataToSubmit.keys
		XCTAssertTrue(resultKeys == validResult.keys, "result keys: \(resultKeys) should match keys: \(validResult.keys)")

		for (key, value) in dataToSubmit {

		}

		XCTAssertTrue(dataToSubmit == validResult, "result: \(dataToSubmit) should match validResult: \(validResult)")
	}

	/// Test deep merge without deep merging arrays with JSON.
	func testDeepMergeJONArrays() {

		let cardNumberValue = "4111-1111-1111-1111"
		let fieldName = "card_data[0].number"

		let extraData: JsonData = [

				"card_data":
					[
						[
							"number": "3714-4963-5398-431",

							"cvv": 123
						]
					]
		]

		let validResult: JsonData = [
			 "card_data":
				[
					[
						"number": "4111-1111-1111-1111",

						"cvv": 123
					]
				]
		]

		let vgsJSON = VGSFieldNameToJSONDataMapper.mapFieldNameToJSON(fieldName, value: cardNumberValue)

		print("vgsJSON: \(vgsJSON)")
		let dataToSubmit = VGSDeepMergeUtils.deepMerge(target: extraData, source: vgsJSON, deepMergeArray: true)
		print("dataToSubmit: \(dataToSubmit)")

		let resultKeys = dataToSubmit.keys
		XCTAssertTrue(resultKeys == validResult.keys, "result keys: \(resultKeys) should match keys: \(validResult.keys)")

		for (key, value) in dataToSubmit {

		}

		XCTAssertTrue(dataToSubmit == validResult, "result: \(dataToSubmit) should match validResult: \(validResult)")
	}
}
