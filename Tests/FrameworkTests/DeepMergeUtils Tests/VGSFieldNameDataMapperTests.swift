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

	/// Test deep merge without deep merging arrays.
	func testDeepMergeConcatenatingArrays() {

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

		let vgsJSON = VGSFieldNameDataMapper(fieldName: fieldName, value: cardNumberValue).jsonToSubmit

		print("vgsJSON: \(vgsJSON)")
		let dataToSubmit = VGSDeepMergeUtils.deepMerge(target: extraData, source: vgsJSON)
		print("dataToSubmit: \(dataToSubmit)")

		let resultKeys = dataToSubmit.keys
		XCTAssertTrue(resultKeys == validResult.keys, "result keys: \(resultKeys) should match keys: \(validResult.keys)")

		for (key, value) in dataToSubmit {

		}

		XCTAssertTrue(dataToSubmit == validResult, "result: \(dataToSubmit) should match validResult: \(validResult)")
	}
}
