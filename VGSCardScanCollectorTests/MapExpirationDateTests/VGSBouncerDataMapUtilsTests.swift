//
//  VGSBouncerDataMapUtilsTests.swift
//  VGSCardScanCollectorTests
//

import Foundation
import XCTest
@testable import VGSCollectSDK
@testable import VGSCardScanCollector

/// Tests for Bouncer data mapping to VGS Collect.
class VGSBouncerDataMapUtilsTests: XCTestCase {

	/// Holds test data.
	struct TestDataMappingItem {
		let format: CradScanDataType
		let expectedText: String
	}

	/// Holds set of data to test specific use case.
	struct TestDataItem {
		let items: [TestDataMappingItem]
		let scannedData: VGSBouncerExpirationDate
	}

	private let testDataItemLongMonth = TestDataItem(items: [
																							TestDataMappingItem(format: .expirationDate, expectedText: "1024"),

																							TestDataMappingItem(format: .expirationDateLong, expectedText: "102024"),

																							TestDataMappingItem(format: .expirationMonth, expectedText: "10"),

																							TestDataMappingItem(format: .expirationYear, expectedText: "24"),

																							TestDataMappingItem(format: .expirationYearLong, expectedText: "2024"),
																							TestDataMappingItem(format: .expirationDateShortYearThenMonth, expectedText: "2410"),
																							TestDataMappingItem(format: .expirationDateLongYearThenMonth, expectedText: "202410")],
																						scannedData: VGSBouncerExpirationDate(monthString: "10", yearString: "24"))

	private let testDataItemShortMonth = TestDataItem(items: [
																							TestDataMappingItem(format: .expirationDate, expectedText: "0325"),

																							TestDataMappingItem(format: .expirationDateLong, expectedText: "032025"),

																							TestDataMappingItem(format: .expirationMonth, expectedText: "03"),

																							TestDataMappingItem(format: .expirationYear, expectedText: "25"),

																							TestDataMappingItem(format: .expirationYearLong, expectedText: "2025"),
																							TestDataMappingItem(format: .expirationDateShortYearThenMonth, expectedText: "2503"),
																							TestDataMappingItem(format: .expirationDateLongYearThenMonth, expectedText: "202503")
	                                          ],
																						scannedData: VGSBouncerExpirationDate(monthString: "03", yearString: "25"))

	private let testDataItemMonthFirst = TestDataItem(items: [
																							TestDataMappingItem(format: .expirationDate, expectedText: "0125"),

																							TestDataMappingItem(format: .expirationDateLong, expectedText: "012025"),

																							TestDataMappingItem(format: .expirationMonth, expectedText: "01"),

																							TestDataMappingItem(format: .expirationYear, expectedText: "25"),

																							TestDataMappingItem(format: .expirationYearLong, expectedText: "2025"),
																							TestDataMappingItem(format: .expirationDateShortYearThenMonth, expectedText: "2501"),
																						   TestDataMappingItem(format: .expirationDateLongYearThenMonth, expectedText: "202501")
	],
																						scannedData: VGSBouncerExpirationDate(monthString: "01", yearString: "25"))

	private let testDataItemMonthLast = TestDataItem(items: [
																							TestDataMappingItem(format: .expirationDate, expectedText: "1225"),

																							TestDataMappingItem(format: .expirationDateLong, expectedText: "122025"),

																							TestDataMappingItem(format: .expirationMonth, expectedText: "12"),

																							TestDataMappingItem(format: .expirationYear, expectedText: "25"),

																							TestDataMappingItem(format: .expirationYearLong, expectedText: "2025"),
																							TestDataMappingItem(format: .expirationDateShortYearThenMonth, expectedText: "2512"),
																							TestDataMappingItem(format: .expirationDateLongYearThenMonth, expectedText: "202512")],
																						scannedData: VGSBouncerExpirationDate(monthString: "12", yearString: "25"))

	/// Tests scan data.
	func testScannedData() {
		verifyScanDataItem(testDataItemShortMonth)
		verifyScanDataItem(testDataItemLongMonth)
		verifyScanDataItem(testDataItemMonthFirst)
		verifyScanDataItem(testDataItemMonthLast)
	}

	// MARK: - Helpers

	/// Verifies scanned data mapping.
	/// - Parameter testDataItem: `TestDataItem` object, holds test data.
	private func verifyScanDataItem(_ testDataItem: TestDataItem) {
		let scannedData = testDataItem.scannedData
		let testData = testDataItem.items

		for index in 0..<testData.count {
			let item = testData[index]
			let format = item.format
			let expectedText = item.expectedText

			let scannedMonth = scannedData.monthString ?? ""
			let scannedYear = scannedData.yearString ?? ""

			let outputText = "Index: \(index). \nCannot convert text for data: month: \(scannedMonth), year: \(scannedYear). \nFormat: \(format). \nExpectedText: \(expectedText)"
			if let text = VGSBouncerDataMapUtils.mapCardExpirationData(scannedData, scannedDataType: format) {
				XCTAssertTrue(text == expectedText, outputText + " \nActual result: \(text)")
			} else {
				XCTFail(outputText + "\nActual result: *nil*")
			}
		}
	}
}
