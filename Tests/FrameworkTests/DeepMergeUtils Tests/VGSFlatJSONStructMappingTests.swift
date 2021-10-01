//
//  VGSFlatJSONStructMappingTests.swift
//  FrameworkTests
//

import Foundation
import XCTest
@testable import VGSCollectSDK

class VGSFlatJSONStructMappingTests: XCTestCase {

	/// Test flat JSON mapping.
	func testFlatJSONMapping() {
		let testData = VGSFieldNameMapperTestDataProvider.provideTestDataForFlatJSON()

		for index in 0..<testData.count {
			let item = testData[index]
			let fieldData = item.fieldsData
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

			let actualJSONToSubmit: JsonData = VGSCollect.mapStoredInpuToFlatJSON(with: extraData, from: textFields)

      let debugDeepMergeOutput = "index: \(index). \nFielsdData *\(fieldData) \nExtra data: \(String(describing: extraData)) \nshould produce \(expectedSubmitJSON), \n\ncomment: \(comment)* \n\nActual result: \(actualJSONToSubmit)"

			XCTAssertTrue(actualJSONToSubmit == expectedSubmitJSON, debugDeepMergeOutput)
		}
	}
}
