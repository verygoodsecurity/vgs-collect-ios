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

	/// Test deep merge without deep merging arrays.
	func testDeepMergeConcatenatingArrays() {

		let dict1: JsonData = [
					"user_id": 1,
					"user_name": "Bob",
					"user_data": [
							"country": "USA"
					],
					"array": [["cvc": "123", "random": "123"]]
		]

		let dict2: JsonData = [
					"user_id": 2,
					"user_name": "Jack",
					"user_data": [
							"country": "Australia"
					],
					"array": [["cvc": 555], ["card_number": "4111-111-1111-1111"]]
		]

		let concatenatedArray: JSONArray =  [["cvc": "123", "random": "123"], ["cvc": 555], ["card_number": "4111-111-1111-1111"]]
		let validResult: JsonData = [
			"user_id": 2,
			"user_name": "Jack",
			"user_data": [
					"country": "Australia"
			],
			"array": concatenatedArray
		]

		let result = VGSDeepMergeUtils.deepMerge(target: dict1, source: dict2)
		let resultKeys = result.keys
		XCTAssertTrue(resultKeys == validResult.keys, "result keys: \(resultKeys) should match keys: \(validResult.keys)")

		for (key, value) in result {
			let textOutput = "key: \(key) value: \(value) should match: "
			switch key {
			case "user_id":
				if let userId = value as? Int {
					XCTAssertTrue(userId == 2, textOutput + "*2*")
				} else {
					XCTFail("incorrect value for \(key), should be of type Int")
				}
			case "user_name":
				if let userName = value as? String {
					XCTAssertTrue(userName == "Jack", textOutput + "*Jack*")
				} else {
					XCTFail("incorrect value for \(key), should be of type String")
				}
			case "user_data":
				if let valueDict = value as? JsonData, let countryValue = valueDict["country"] as? String {
						XCTAssertTrue(countryValue == "Australia", "country value: \(countryValue) should match *Australia*")
				} else {
					XCTFail("incorrect value for \(key), should be of type JsonObject")
				}
			case "array":
				if let valueArray = value as? JSONArray {
					XCTAssertTrue(valueArray == concatenatedArray, "valueArray: \(valueArray) should match concatenatedArray: \(concatenatedArray)")
				} else {
					XCTFail("incorrect value for \(key), should be of type JSONArray")
				}
			default:
				continue
			}
		}

		XCTAssertTrue(validResult == result, "result: \(result) should match validResult: \(validResult)")
	}
}

internal func == (lhs: JsonData, rhs: JsonData ) -> Bool {
		return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

internal func == (lhs: JSONArray, rhs: JSONArray ) -> Bool {
	let equalElementsCount = lhs.count == rhs.count

	if !equalElementsCount {
		return false
	}

	var isEqual = true
	for index in 0..<rhs.count {
		let value1 = lhs[index]
		let value2 = rhs[index]

		isEqual = value1 == value2
	}

	return isEqual
}

internal  func resolve<T>(_ jsonDictionary: JsonData, keyPath: String) -> T? {
		var current: Any? = jsonDictionary

		keyPath.split(separator: ".").forEach { component in
				if let maybeInt = Int(component), let array = current as? Array<Any> {
						current = array[maybeInt]
				} else if let dictionary = current as? JsonData {
						current = dictionary[String(component)]
				}
		}

		return current as? T
}
