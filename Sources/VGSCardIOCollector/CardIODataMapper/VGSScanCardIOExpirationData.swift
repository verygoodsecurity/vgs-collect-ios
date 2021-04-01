//
//  VGSScanCardIOExpirationData.swift
//  VGSCardIOCollector
//

import Foundation

/// Holds scanned expiration date data (CardIO).
/// Card IO holds exp date in `UInt` format: `03/2025` => `3` for month, `2025` for year.
internal struct VGSScanCardIOExpirationData {
	/// Scanned month.
	internal let month: UInt

	/// Scanned year.
	internal let year: UInt
}
