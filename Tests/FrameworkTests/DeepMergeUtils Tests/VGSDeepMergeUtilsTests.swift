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
		let value: Any

		init?(json: JsonData) {
			guard let name = json["fieldName"] as? String,
						let value = json["fieldValue"] as? Any else {
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

	func testDeepMergeJSONOverwritingArrays() {

	}
}
