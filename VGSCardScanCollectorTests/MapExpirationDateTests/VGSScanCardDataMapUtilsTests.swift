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
	struct TestData {
		let format: CradScanDataType
		let expectedText: String
	}

	/// Tests scanned data for long month.
	func testScanDataMappingWithLongMonth() {
		let scannedData = VGSScanCardExpirationData(monthString: "10", yearString: "24")

		let testData: [TestData] = [
			TestData(format: .expirationDate, expectedText: "1024"),

			TestData(format: .expirationDateLong, expectedText: "102024"),

			TestData(format: .expirationMonth, expectedText: "10"),

			TestData(format: .expirationYear, expectedText: "24"),

			TestData(format: .expirationYearLong, expectedText: "2024")
		]

		for index in 0..<testData.count {
			let item = testData[index]
			let format = item.format
			let expectedText = item.expectedText

			let outputText = "Index: \(index). \nCannot convert text for data: month: 10, year: 24. \nFormat: \(format). \nExpectedText: \(expectedText)"
			if let text = VGSScanCardDataMapUtils.mapCardExpirationData(scannedData, scannedDataType: format) {
				XCTAssertTrue(text == expectedText, outputText + "actual result: \(text)")
			} else {
				XCTFail(outputText + "actual result: *nil*")
			}
		}
	}

	/// Tests scanned data for short month.
	func testScanDataMappingWithShortMonth() {
		let scannedData = VGSScanCardExpirationData(monthString: "03", yearString: "25")

		let testData: [TestData] = [
			TestData(format: .expirationDate, expectedText: "0325"),

			TestData(format: .expirationDateLong, expectedText: "032025"),

			TestData(format: .expirationMonth, expectedText: "03"),

			TestData(format: .expirationYear, expectedText: "25"),

			TestData(format: .expirationYearLong, expectedText: "2025")
		]

		for index in 0..<testData.count {
			let item = testData[index]
			let format = item.format
			let expectedText = item.expectedText

			let outputText = "Index: \(index). \nCannot convert text for data: month: 03, year: 25. \nFormat: \(format). \nExpectedText: \(expectedText)"
			if let text = VGSScanCardDataMapUtils.mapCardExpirationData(scannedData, scannedDataType: format) {
				XCTAssertTrue(text == expectedText, outputText + "actual result: \(text)")
			} else {
				XCTFail(outputText + "actual result: *nil*")
			}
		}
	}
}
