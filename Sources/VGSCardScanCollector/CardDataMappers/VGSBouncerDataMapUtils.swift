//
//  VGSBouncerDataMapUtils.swift
//  VGSCollectSDK
//

import Foundation
#if !COCOAPODS
import VGSCollectSDK
#endif

/// Holds mapping utils for scanned card data.
internal final class VGSBouncerDataMapUtils {

	// MARK: - Constants

	/// Valid months range.
	private static let monthsRange = 1...12

	// MARK: - Interface

	/// Maps scanned expiration data to expected format.
	/// - Parameters:
	///   - data: `VGSBouncerExpirationDate` object, scanned expiry date data.
	///   - format: `CradScanDataType` object, card data type.
	/// - Returns: `String?`, formatted string or `nil`.
	internal static func mapCardExpirationData(_ data: VGSBouncerExpirationDate, scannedDataType: CradScanDataType) -> String? {
		switch scannedDataType {
		case .cardNumber, .name:
			return nil
		case  .expirationDate:
			return mapDefaultExpirationDate(data.monthString, scannedExpYear: data.yearString)
		case .expirationDateLong:
			return mapLongExpirationDate(data.monthString, scannedExpYear: data.yearString)
		case .expirationMonth:
			return mapMonth(data.monthString)
		case .expirationYear:
			return mapYear(data.yearString)
		case .expirationYearLong:
			return mapYearLong(data.yearString)
		}
	}

	// MARK: - Helpers

	/// Maps scanned exp month and year to valid format (MM/YY).
	/// - Parameters:
	///   - scannedExpMonth: `String` object, scanned expiry month.
	///   - scannedExpYear: `String` object, scanned expiry year.
	/// - Returns: `String?`, composed text or nil if scanned info is invalid.
	private static func mapDefaultExpirationDate(_ scannedExpMonth: String?, scannedExpYear: String?) -> String? {
		guard let month = mapMonth(scannedExpMonth), let year = mapYear(scannedExpYear) else {
			return nil
		}

		return "\(month)\(year)"
	}

	/// Maps scanned exp month and year to long expiration date format (MM/YYYY).
	/// - Parameters:
	///   - scannedExpMonth: `String` object, scanned expiry month.
	///   - scannedExpYear: `String` object, scanned expiry year.
	/// - Returns: `String?`, composed text or nil if scanned info is invalid.
	private static func mapLongExpirationDate(_ scannedExpMonth: String?, scannedExpYear: String?) -> String? {
		guard let month = mapMonth(scannedExpMonth), let longYear = mapYearLong(scannedExpYear) else {
			return nil
		}

		return "\(month)\(longYear)"
	}

	/// Maps scanned expiry month to short format (YY) string.
	/// - Parameter scannedExpYear: `String?` object, scanned expiry year.
	/// - Returns: `String?`, year text or nil if scanned info is invalid.
	private static func mapMonth(_ scannedExpMonth: String?) -> String? {
		guard let month = monthInt(from: scannedExpMonth) else {return nil}

		let formattedMonthString = formatMonthString(from: month)
		return formattedMonthString
	}

	/// Maps scanned expiry year to short format (YY) string.
	/// - Parameter scannedExpYear: `String?` object, scanned expiry year.
	/// - Returns: `String?`, year text or nil if scanned info is invalid.
	private static func mapYear(_ scannedExpYear: String?) -> String? {
		guard let year = yearInt(from: scannedExpYear) else {return nil}

		return "\(year)"
	}

	/// Maps scanned expiry year to long format (YYYY) string.
	/// - Parameter scannedExpYear: `String?` object, scanned expiry year.
	/// - Returns: `String?`, year text or nil if scanned info is invalid.
	private static func mapYearLong(_ scannedExpYear: String?) -> String? {
		guard let year = yearInt(from: scannedExpYear) else {return nil}

		return longYearString(from: year)
	}

	/// Converts year to long format string.
	/// - Parameter shortYear: `Int` object, should be short year.
	/// - Returns: `String` with long year format.
	private static func longYearString(from shortYear: Int) -> String {
		return "20\(shortYear)"
	}

	/// Checks if month (Int) is valid.
	/// - Parameter month: `Int` object, month to verify.
	/// - Returns: `Bool` object, `true` if is valid.
	private static func isMonthValid(_ month: Int) -> Bool {
		return monthsRange ~= month
	}

	/// Checks if year (Int) is valid.
	/// - Parameter year: `Int` object, year to verify.
	/// - Returns: `Bool` object, `true` if is valid.
	private static func isYearValid(_ year: Int) -> Bool {
		// CardScan returns year in short format: `2024` -> `24`.
		return year >= VGSCalendarUtils.currentYearShort
	}

	/// Provides month Int from text.
	/// - Parameter monthString: `String` object, month as text.
	/// - Returns: `Int?`, valid month or `nil`.
	private static func monthInt(from monthString: String?) -> Int? {
		guard let month = monthString, !month.isEmpty,
					let monthInt = Int(month), isMonthValid(monthInt) else {
			return nil
		}

		return monthInt
	}

	/// Provides year Int from text.
	/// - Parameter yearString: `String` object, year as text.
	/// - Returns: `Int?`, valid year or `nil`.
	private static func yearInt(from yearString: String?) -> Int? {
		guard let year = yearString, !year.isEmpty,
					let yearInt = Int(year), isYearValid(yearInt) else {
			return nil
		}

		return yearInt
	}

	/// Formats month int.
	/// - Parameter monthInt: `Int`, should be month.
	/// - Returns: `String` object, formatted month.
	private static func formatMonthString(from monthInt: Int) -> String {
		// Add `0` for month less than 10.
		let monthString = monthInt < 10 ? "0\(monthInt)" : "\(monthInt)"
		return monthString
	}
}
