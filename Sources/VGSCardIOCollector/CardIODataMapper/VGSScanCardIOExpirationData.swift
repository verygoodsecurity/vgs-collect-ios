//
//  VGSScanCardIOExpirationData.swift
//  VGSCardIOCollector
//

import Foundation

/// Holds scanned expiration date data (CardIO).
/// CardIO sends to delegate exp date in `UInt` format, CardIO text: `03/25` => output is `3` for month, `2025` for year.
internal struct VGSScanCardIOExpirationData {
	/// Scanned month.
	internal let month: UInt

	/// Scanned year.
	internal let year: UInt
}
