//
//  VGSScanCardDataMapUtilsTests.swift
//  VGSCardScanCollectorTests
//

import Foundation
import XCTest
@testable import VGSCollectSDK
@testable import VGSCardScanCollector

class VGSScanCardDataMapUtilsTests: XCTestCase {

	/// Holds test data.
	struct TestDataMappingItem {
		let format: CradScanDataType
		let expectedText: String
	}

	struct TestDataItem {
		let items: [TestDataMappingItem]
		let scannedData: VGSScanCardExpirationData
	}

	private let testDataItemLongMonth = TestDataItem(items: [
																							TestDataMappingItem(format: .expirationDate, expectedText: "1024"),

																							TestDataMappingItem(format: .expirationDateLong, expectedText: "102024"),

																							TestDataMappingItem(format: .expirationMonth, expectedText: "10"),

																							TestDataMappingItem(format: .expirationYear, expectedText: "24"),

																							TestDataMappingItem(format: .expirationYearLong, expectedText: "2024")],
																						scannedData: VGSScanCardExpirationData(monthString: "10", yearString: "24"))

	private let testDataItemShortMonth = TestDataItem(items: [
																							TestDataMappingItem(format: .expirationDate, expectedText: "0325"),

																							TestDataMappingItem(format: .expirationDateLong, expectedText: "032025"),

																							TestDataMappingItem(format: .expirationMonth, expectedText: "03"),

																							TestDataMappingItem(format: .expirationYear, expectedText: "25"),

																							TestDataMappingItem(format: .expirationYearLong, expectedText: "2025")],
																						scannedData: VGSScanCardExpirationData(monthString: "03", yearString: "25"))

	/// Test scan data.
	func testScannedData() {
		verifyScanDataItem(testDataItemShortMonth)
		verifyScanDataItem(testDataItemLongMonth)
	}

	// MARK: - Helpers

	/// Verify scanned data mapping.
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
			if let text = VGSScanCardDataMapUtils.mapCardExpirationData(scannedData, scannedDataType: format) {
				XCTAssertTrue(text == expectedText, outputText + "actual result: \(text)")
			} else {
				XCTFail(outputText + "actual result: *nil*")
			}
		}
	}
}
