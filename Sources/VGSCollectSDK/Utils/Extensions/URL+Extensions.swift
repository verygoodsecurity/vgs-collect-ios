//
//  URL+Extensions.swift
//  VGSCollectSDK
//
//  Created on 16.02.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

internal extension URL {
	/// Check if URL has secure scheme.
	/// - Returns: `true` if has secure scheme.
	func hasSecureScheme() -> Bool {
		return scheme == "https"
	}

	static func urlWithSecureScheme(from url: URL) -> URL? {
		var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
		components?.scheme = "https"

		return components?.url
	}
}
