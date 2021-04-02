//
//  VGSCardIODataMapUtils.swift
//  VGSCardIOCollector
//

import Foundation
import VGSCollectSDK

/// Holds mapping utils for scanned card data.
internal final class VGSCardIODataMapUtils {

	// MARK: - Constants

	/// Valid months range.
	private static let monthsRange = 1...12

	// MARK: - Interface

	/// Maps scanned expiration data to expected format.
	/// - Parameters:
	///   - data: `VGSCardIOExpirationDate` object, scanned expiry date data.
	///   - scannedDataType: `CradIODataType` object, CardIO data type.
	/// - Returns: `String?`, formatted string or `nil`.
	internal static func mapCardExpirationData(_ data: VGSCardIOExpirationDate, scannedDataType: CradIODataType) -> String? {
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

	/// Maps scanned exp month and year to valid format (MM/YY).
	/// - Parameters:
	///   - scannedExpMonth: `UInt` object, scanned expiry month.
	///   - scannedExpYear: `UInt` object, scanned expiry year.
	/// - Returns: `String?`, composed text or nil if scanned info is invalid.
	private static func mapDefaultExpirationDate(_ scannedExpMonth: UInt, scannedExpYear: UInt) -> String? {
		guard let month = mapMonth(scannedExpMonth), let year = mapYear(scannedExpYear) else {
			return nil
		}

		return "\(month)\(year)"
	}

	/// Maps scanned exp month and year to long expiration date format (MM/YYYY).
	/// - Parameters:
	///   - scannedExpMonth: `UInt` object, scanned expiry month.
	///   - scannedExpYear: `UInt` object, scanned expiry year.
	/// - Returns: `String?`, composed text or nil if scanned info is invalid.
	private static func mapLongExpirationDate(_ scannedExpMonth: UInt, scannedExpYear: UInt) -> String? {
		guard let month = mapMonth(scannedExpMonth), let longYear = mapYearLong(scannedExpYear) else {
			return nil
		}

		return "\(month)\(longYear)"
	}

	/// Maps scanned expiry month to short format (MM) string.
	/// - Parameter scannedExpYear: `UInt` object, scanned expiry year.
	/// - Returns: `String?`, year text or nil if scanned info is invalid.
	private static func mapMonth(_ scannedExpMonth: UInt) -> String? {
		guard let month = monthInt(from: scannedExpMonth) else {return nil}

		let formattedMonthString = formatMonthString(from: month)
		return formattedMonthString
	}

	/// Maps scanned expiry year to short format (YY) string.
	/// - Parameter scannedExpYear: `UInt` object, scanned expiry year.
	/// - Returns: `String?`, year text or nil if scanned info is invalid.
	private static func mapYear(_ scannedExpYear: UInt) -> String? {
		guard let year = yearInt(from: scannedExpYear) else {return nil}

		// CardIO holds year in long format (2025), convert to short (25) format manually.
		return shortYearString(from: year)
	}

	/// Maps scanned expiry year to long format (YYYY) string.
	/// - Parameter scannedExpYear: `UInt` object, scanned expiry year.
	/// - Returns: `String?`, year text or nil if scanned info is invalid.
	private static func mapYearLong(_ scannedExpYear: UInt) -> String? {
		guard let year = yearInt(from: scannedExpYear) else {return nil}

		return "\(year)"
	}

	/// Converts year to long format string.
	/// - Parameter longYear: `UInt` object, should be short year.
	/// - Returns: `String` with long year format.
	private static func shortYearString(from longYear: UInt) -> String {
		return String("\(longYear)".suffix(2))
	}

	/// Checks if month (UInt) is valid.
	/// - Parameter month: `UInt` object, month to verify.
	/// - Returns: `Bool` object, `true` if is valid.
	private static func isMonthValid(_ month: UInt) -> Bool {
		return monthsRange ~= Int(month)
	}

	/// Checks if year (Int) is valid.
	/// - Parameter year: `UInt` object, year to verify.
	/// - Returns: `Bool` object, `true` if is valid.
	private static func isYearValid(_ year: UInt) -> Bool {
		// CardIO returns year in long format: `2025`.
		return year >= VGSCalendarUtils.currentYear
	}

	/// Provides month Int.
	/// - Parameter month: `UInt` object, month from CardIO.
	/// - Returns: `UInt?`, valid month or `nil`.
	private static func monthInt(from month: UInt) -> UInt? {
		guard isMonthValid(month) else {
			return nil
		}

		return month
	}

	/// Provides year Int.
	/// - Parameter year: `UInt` object, year from CardIO.
	/// - Returns: `UInt?`, valid year or `nil`.
	private static func yearInt(from year: UInt) -> UInt? {
		guard isYearValid(year) else {
			return nil
		}

		return year
	}

	/// Formats month int.
	/// - Parameter monthInt: `UInt` object, should be month.
	/// - Returns: `String` object, formatted month.
	private static func formatMonthString(from monthInt: UInt) -> String {
		// Add `0` for month less than 10.
		let monthString = monthInt < 10 ? "0\(monthInt)" : "\(monthInt)"
		return monthString
	}
}
