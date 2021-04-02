//
//  VGSCardIODataMapUtilsTests.swift
//  VGSCardIOCollectorTests
//

import Foundation
import XCTest
@testable import VGSCollectSDK
@testable import VGSCardIOCollector

/// Tests for CardIO data mapping to VGS Collect.
class VGSBouncerDataMapUtilsTests: XCTestCase {

	/// Holds test data.
	struct TestDataMappingItem {
		let format: CradIODataType
		let expectedText: String
	}

	/// Holds set of data to test specific use case.
	struct TestDataItem {
		let items: [TestDataMappingItem]
		let scannedData: VGSCardIOExpirationDate
	}

	private let testDataItemLongMonth = TestDataItem(items: [
																							TestDataMappingItem(format: .expirationDate, expectedText: "1024"),

																							TestDataMappingItem(format: .expirationDateLong, expectedText: "102024"),

																							TestDataMappingItem(format: .expirationMonth, expectedText: "10"),

																							TestDataMappingItem(format: .expirationYear, expectedText: "24"),

																							TestDataMappingItem(format: .expirationYearLong, expectedText: "2024")],
																						scannedData: VGSCardIOExpirationDate(month: 10, year: 2024))

	private let testDataItemShortMonth = TestDataItem(items: [
																							TestDataMappingItem(format: .expirationDate, expectedText: "0325"),

																							TestDataMappingItem(format: .expirationDateLong, expectedText: "032025"),

																							TestDataMappingItem(format: .expirationMonth, expectedText: "03"),

																							TestDataMappingItem(format: .expirationYear, expectedText: "25"),

																							TestDataMappingItem(format: .expirationYearLong, expectedText: "2025")],
																						scannedData: VGSCardIOExpirationDate(month: 3, year: 2025))

	private let testDataItemMonthFirst = TestDataItem(items: [
																							TestDataMappingItem(format: .expirationDate, expectedText: "0125"),

																							TestDataMappingItem(format: .expirationDateLong, expectedText: "012025"),

																							TestDataMappingItem(format: .expirationMonth, expectedText: "01"),

																							TestDataMappingItem(format: .expirationYear, expectedText: "25"),

																							TestDataMappingItem(format: .expirationYearLong, expectedText: "2025")],
																							scannedData: VGSCardIOExpirationDate(month: 1, year: 2025))

	private let testDataItemMonthLast = TestDataItem(items: [
																							TestDataMappingItem(format: .expirationDate, expectedText: "1225"),

																							TestDataMappingItem(format: .expirationDateLong, expectedText: "122025"),

																							TestDataMappingItem(format: .expirationMonth, expectedText: "12"),

																							TestDataMappingItem(format: .expirationYear, expectedText: "25"),

																							TestDataMappingItem(format: .expirationYearLong, expectedText: "2025")],
																						  scannedData: VGSCardIOExpirationDate(month: 12, year: 2025))

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

			let scannedMonth = scannedData.month
			let scannedYear = scannedData.year

			let outputText = "Index: \(index). \nCannot convert text for data: month: \(scannedMonth), year: \(scannedYear). \nFormat: \(format). \nExpectedText: \(expectedText)"
			if let text = VGSCardIODataMapUtils.mapCardExpirationData(scannedData, scannedDataType: format) {
				XCTAssertTrue(text == expectedText, outputText + "\nActual result: \(text)")
			} else {
				XCTFail(outputText + "\nActual result: *nil*")
			}
		}
	}
}
