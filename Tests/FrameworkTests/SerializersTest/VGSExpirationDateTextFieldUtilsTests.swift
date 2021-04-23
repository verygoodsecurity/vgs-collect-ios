//
//  VGSExpirationDateTextFieldUtilsTests.swift
//  FrameworkTests
//

import Foundation
import XCTest
@testable import VGSCollectSDK

class VGSExpirationDateTextFieldUtilsTests: VGSCollectBaseTestCase {

	struct TestDateFormatItem {
		let month: Int
		let year: Int
		let format: VGSCardExpDateFormat
		let expectedOutput: String
	}

	let testData: [TestDateFormatItem] = [
		// Short year.
		TestDateFormatItem(month: 1, year: 2026, format: .shortYear, expectedOutput: "0126"),
		TestDateFormatItem(month: 12, year: 2026, format: .shortYear, expectedOutput: "1226"),
		TestDateFormatItem(month: 3, year: 2026, format: .shortYear, expectedOutput: "0326"),

		// Long year.
		TestDateFormatItem(month: 1, year: 2026, format: .longYear, expectedOutput: "012026"),
		TestDateFormatItem(month: 12, year: 2026, format: .longYear, expectedOutput: "122026"),
		TestDateFormatItem(month: 3, year: 2026, format: .longYear, expectedOutput: "032026"),

		// Short year then month.
		TestDateFormatItem(month: 1, year: 2026, format: .shortYearThenMonth, expectedOutput: "2601"),
		TestDateFormatItem(month: 12, year: 2026, format: .shortYearThenMonth, expectedOutput: "2612"),
		TestDateFormatItem(month: 3, year: 2026, format: .shortYearThenMonth, expectedOutput: "2603"),

		// Long year then month.
		TestDateFormatItem(month: 1, year: 2026, format: .longYearThenMonth, expectedOutput: "202601"),
		TestDateFormatItem(month: 12, year: 2026, format: .longYearThenMonth, expectedOutput: "202612"),
		TestDateFormatItem(month: 3, year: 2026, format: .longYearThenMonth, expectedOutput: "202603")
	]

	// MARK: - Override

	override func setUp() {
			super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	// MARK: - Tests

	/// Test date mapping utils.
	func testDataFormatsMapping() {
		for index in 0..<testData.count {
			let item = testData[index]
			let month = item.month
			let year = item.year
			let format = item.format
			let expectedOutput = item.expectedOutput

			let actualResult = VGSExpirationDateTextFieldUtils.mapDatePickerExpirationDataForFieldFormat(format, month: month, year: year)
			XCTAssertTrue(actualResult == expectedOutput, "index: \(index) \nShould produce \(expectedOutput) \nActual result: \(actualResult) \nformat: \(format) \nmonth: \(month) \nyear(year)")
		}
	}
}
