//
//  VGSFieldNameMapUtilsTests.swift
//  FrameworkTests
//
//  Created on 10.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation
import XCTest
@testable import VGSCollectSDK

/// Test fieldName dot notaion mapping.
class VGSFieldNameMapUtilsTests: XCTestCase {

	/// Holds test data.
	struct VGSFieldNameMapTestData {
		let fieldName: String
		let subscripts: [VGSFieldNameSubscriptType]
		let dotMapNotaionKey: String
		let comment: String?
	}

	/// Test fieldnames dot nonation mapping to subscripts.
	func testFieldNames() {
		let testData: [VGSFieldNameMapTestData] = [
			// 0.
			VGSFieldNameMapTestData(fieldName: "data.card_number",
															subscripts: [.key("data"), .key("card_number")],
															dotMapNotaionKey: "data.card_number",
															comment: "Only JSON keys"),

			// 1.
			VGSFieldNameMapTestData(fieldName: "card_number",
															subscripts: [.key("card_number")],
															dotMapNotaionKey: "card_number",
															comment: "Single JSON key"),

			// 2.
			VGSFieldNameMapTestData(fieldName: "data.card_number[1]",
															subscripts: [.key("data"), .key("card_number"), .index(1)],
															dotMapNotaionKey: "data.card_number.1",
															comment: "JSON keys and one index"),

			// 3.
			VGSFieldNameMapTestData(fieldName: "data[0].card_number[1]",
															subscripts: [.key("data"), .index(0), .key("card_number"), .index(1)],
															dotMapNotaionKey: "data.0.card_number.1",
															comment: "JSON keys and multiple indices"),

			// 4.
			VGSFieldNameMapTestData(fieldName: "data[0][2].card_number[1]",
															subscripts: [.key("data"), .index(0), .key("card_number"), .index(1)],
															dotMapNotaionKey: "data.0.card_number.1",
															comment: "JSON keys and multiple indices in one segment. We track only first index [0]"),

			// 5.
			VGSFieldNameMapTestData(fieldName: "data[0][2]yyy.card_number[1]",
															subscripts: [.key("data"), .index(0), .key("card_number"), .index(1)],
															dotMapNotaionKey: "data.0.card_number.1",
															comment: "JSON keys and multiple indices in one segment. We track only first index [0]. No more than 2 subscripts separated by *.*"),

			// 6.
			VGSFieldNameMapTestData(fieldName: "data[0]yyy.card_number[1]",
															subscripts: [.key("data"), .index(0), .key("card_number"), .index(1)],
															dotMapNotaionKey: "data.0.card_number.1",
															comment: "JSON keys and multiple indices in one segment. We track only first index [0]. No more than 2 subscripts separated by *.*"),

			// 7.
			VGSFieldNameMapTestData(fieldName: "data[0].card_number[1].number",
															subscripts: [.key("data"), .index(0), .key("card_number"), .index(1), .key("number")],
															dotMapNotaionKey: "data.0.card_number.1.number",
															comment: "Multiple keys and indices.")

		]

		for index in 0..<testData.count {
			let item = testData[index]
			let fieldName = item.fieldName
			let exprectedSubscripts = item.subscripts
			let expectedDotNotationKey = item.dotMapNotaionKey
			let comment = item.comment ?? ""

			let actualResult = VGSFieldNameMapUtils.mapFieldNameToSubscripts(fieldName)

			let debugSubscriptsOutput = "index: \(index) fieldName *\(fieldName) should produce \(exprectedSubscripts), comment: \(comment)*.Actual result: \(actualResult)"

			XCTAssertTrue(actualResult == exprectedSubscripts, debugSubscriptsOutput)

			let actualDotMapNotationKey = actualResult.dotMapNotationKey

			let debugKeyNotationOutput = "index: \(index) fieldName *\(fieldName) should produce \(expectedDotNotationKey), comment: \(comment)*. Actual result: \(actualDotMapNotationKey)"

			XCTAssertTrue(actualDotMapNotationKey == expectedDotNotationKey, debugKeyNotationOutput)
		}
	}
}
