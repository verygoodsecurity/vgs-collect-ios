//
//  VGSScanCardIODataMapUtils.swift
//  VGSCardIOCollector
//

import Foundation
import VGSCollectSDK

/// Holds mapping utils for scanned card data.
internal final class VGSScanCardIODataMapUtils {

	// MARK: - Constants

	/// Valid months range.
	private static let monthsRange = 1...12

	// MARK: - Interface

	/// Maps scanned expiration data to expected format.
	/// - Parameters:
	///   - data: `VGSScanCardIOExpirationData` object, holds scanned expiry date data.
	///   - format: `CradIODataType` object, CardIO data type.
	/// - Returns: `String?`, formatted string or `nil`.
	internal static func mapCardExpirationData(_ data: VGSScanCardIOExpirationData, scannedDataType: CradIODataType) -> String? {
		switch scannedDataType {
		case .cardNumber, .cvc:
			return nil
		case  .expirationDate:
			return mapDefaultExpirationDate(data.month, scannedExpYear: data.year)
		case .expirationDateLong:
			return mapLongExpirationDate(data.month, scannedExpYear: data.year)
		case .expirationMonth:
			return mapMonth(data.month)
		case .expirationYear:
			return mapYear(data.year)
		case .expirationYearLong:
			return mapYearLong(data.year)
		}
	}

	// MARK: - Helpers

	/// Map scanned exp month and year to valid format (MM/YY).
	/// - Parameters:
	///   - scannedExpMonth: `Int` object, scanned expiry month.
	///   - scannedExpYear: `Int` object, scanned expiry year.
	/// - Returns: `String?`, composed text or nil if scanned info is invalid.
	private static func mapDefaultExpirationDate(_ scannedExpMonth: Int, scannedExpYear: Int) -> String? {
		guard let month = mapMonth(scannedExpMonth), let year = mapYear(scannedExpYear) else {
			return nil
		}

		return "\(month)\(year)"
	}

	/// Map scanned exp month and year to long expiration date format (MM/YYYY).
	/// - Parameters:
	///   - scannedExpMonth: `String` object, scanned expiry month.
	///   - scannedExpYear: `String` object, scanned expiry year.
	/// - Returns: `String?`, composed text or nil if scanned info is invalid.
	private static func mapLongExpirationDate(_ scannedExpMonth: Int, scannedExpYear: Int) -> String? {
		guard let month = mapMonth(scannedExpMonth), let longYear = mapYearLong(scannedExpYear) else {
			return nil
		}

		return "\(month)\(longYear)"
	}

	/// Maps scanned expiry month to short format (MM) string.
	/// - Parameter scannedExpYear: `Int` object, scanned expiry year.
	/// - Returns: `String?`, year text or nil if scanned info is invalid.
	private static func mapMonth(_ scannedExpMonth: Int) -> String? {
		guard let month = monthInt(from: scannedExpMonth) else {return nil}

		let formattedMonthString = formatMonthString(from: month)
		return formattedMonthString
	}

	/// Maps scanned expiry year to short format (YY) string.
	/// - Parameter scannedExpYear: `Int` object, scanned expiry year.
	/// - Returns: `String?`, year text or nil if scanned info is invalid.
	private static func mapYear(_ scannedExpYear: Int) -> String? {
		guard let year = yearInt(from: scannedExpYear) else {return nil}

		return shortYearString(from: year)
	}

	/// Maps scanned expiry year to long format (YYYY) string.
	/// - Parameter scannedExpYear: `Int` object, scanned expiry year.
	/// - Returns: `String?`, year text or nil if scanned info is invalid.
	private static func mapYearLong(_ scannedExpYear: Int) -> String? {
		guard let year = yearInt(from: scannedExpYear) else {return nil}

		return "\(year)"
	}

	/// Converts year to long format string.
	/// - Parameter shortYear: `Int` object, should be short year.
	/// - Returns: `String` with long year format.
	private static func shortYearString(from longYear: Int) -> String {
		return String("\(longYear)".suffix(2))
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
		// CardIO returns year in long format: `2025`.
		return year >= VGSCalendarUtils.currentYear
	}

	/// Provides month Int.
	/// - Parameter month: `Int` object, month from CardIO.
	/// - Returns: `Int?`, valid month or `nil`.
	private static func monthInt(from month: Int) -> Int? {
		guard isMonthValid(month) else {
			return nil
		}

		return month
	}

	/// Provides year Int.
	/// - Parameter yearString: `String` object, year from CardIO.
	/// - Returns: `Int?`, valid year or `nil`.
	private static func yearInt(from year: Int) -> Int? {
		guard isYearValid(year) else {
			return nil
		}

		return year
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
