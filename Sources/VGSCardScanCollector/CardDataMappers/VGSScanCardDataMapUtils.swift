//
//  VGSScanCardDataMapUtils.swift
//  VGSCollectSDK
//

import Foundation
#if !COCOAPODS
import VGSCollectSDK
#endif

/// Holds mapping utils for scanned card data.
internal final class VGSScanCardDataMapUtils {

	/// Valid months range.
	private static let monthsRange = 1...12

	/// Map scanned exp month and year to valid format (MM/YY).
	/// - Parameters:
	///   - scannedExpMonth: `String` object, scanned expiry month.
	///   - scannedExpYear: `String` object, scanned expiry year.
	/// - Returns: `String?`, composed text or nil if scanned info is invalid.
	internal static func mapDefaultExpirationDate(_ scannedExpMonth: String?, scannedExpYear: String?) -> String? {
		guard let month = monthInt(from: scannedExpMonth), let year = yearInt(from: scannedExpYear) else {
			return nil
		}

		let formattedMonthString = formatMonthString(from: month)
		return "\(formattedMonthString)\(year)"
	}

	/// Map scanned exp month and year to long expiration date format (MM/YYYY).
	/// - Parameters:
	///   - scannedExpMonth: `String` object, scanned expiry month.
	///   - scannedExpYear: `String` object, scanned expiry year.
	/// - Returns: `String?`, composed text or nil if scanned info is invalid.
	internal static func mapLongExpirationDate(_ scannedExpMonth: String?, scannedExpYear: String?) -> String? {
		guard let month = monthInt(from: scannedExpMonth), let year = yearInt(from: scannedExpYear) else {
			return nil
		}

		let formattedMonthString = formatMonthString(from: month)
		let longYear = longYearString(from: year)
		return "\(formattedMonthString)\(longYear)"
	}

	// MARK: - Helpers

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

	/// Format month int.
	/// - Parameter monthInt: `Int`, should be month.
	/// - Returns: `String` object, formatted month.
	private static func formatMonthString(from monthInt: Int) -> String {
		// Add `0` for month less than 10.
		let monthString = monthInt < 10 ? "0\(monthInt)" : "\(monthInt)"
		return monthString
	}
}
