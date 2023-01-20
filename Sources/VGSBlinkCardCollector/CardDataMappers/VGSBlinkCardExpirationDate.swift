import Foundation
#if !COCOAPODS
import VGSCollectSDK
#endif

/// Holds scanned expiration date data.
/// BlinkCard holds scanned data expiration date with two separate Ints.
internal struct VGSBlinkCardExpirationDate {
	/// Scanned month.
  let month: Int
  /// Month converted to String: "01"
  let monthString: String
	/// Scanned year: YYYY
  let year: Int
  /// Scanned year short: YY
  let shortYear: Int
    
  init(_ month: Int, year: Int) {
    self.month = month
    // Normalize month to format "01"
    self.monthString = Self.formatMonthString(from: month)
    self.year = year
    self.shortYear = year - 2000
  }
  
  // MARK: - Helpers

  /// Maps scanned exp month and year to valid format (MM/YY).
  /// - Returns: `String`, composed text or nil if scanned info is invalid.
  func mapDefaultExpirationDate() -> String {
    return "\(monthString)\(shortYear)"
  }

  /// Maps scanned exp month and year to long expiration date format (MM/YYYY).
  /// - Returns: `String`, composed text or nil if scanned info is invalid.
  func mapLongExpirationDate() -> String {
    return "\(monthString)\(year)"
  }
  
  /// Maps scanned exp month and year to valid format starting with  year  (YY/MM).
  /// - Returns: `String`, composed text or nil if scanned info is invalid.
  func mapExpirationDateWithShortYearFirst() -> String {
    return "\(shortYear)\(monthString)"
  }
  
  /// Maps scanned exp month and year to long expiration date format starting with  year (YYYY/MM).
  /// - Returns: `String`, composed text or nil if scanned info is invalid.
  func mapLongExpirationDateWithLongYearFirst() -> String {
    return "\(year)\(monthString)"
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
