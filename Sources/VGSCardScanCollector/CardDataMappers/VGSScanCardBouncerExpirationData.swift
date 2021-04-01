//
//  VGSScanCardBouncerExpirationData.swift
//  VGSCardScanCollector
//

import Foundation

/// Holds scanned expiration date data.
/// Bouncer holds scanned data in format `0325` -> `03` for month, `25` for year.
internal struct VGSScanCardBouncerExpirationData {
	/// Scanned month.
	internal let monthString: String?

	/// Scanned year.
	internal let yearString: String?
}
