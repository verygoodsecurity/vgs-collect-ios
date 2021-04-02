//
//  VGSBouncerExpirationDate.swift
//  VGSCardScanCollector
//

import Foundation

/// Holds scanned expiration date data.
/// Bouncer holds scanned data expiration date with two separate strings.
/// `03/25` on card -> `03` for month, `25` for year. Year is always `YY` in short format.
internal struct VGSBouncerExpirationDate {
	/// Scanned month.
	internal let monthString: String?

	/// Scanned year.
	internal let yearString: String?
}
