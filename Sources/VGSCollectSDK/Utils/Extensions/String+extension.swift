//
//  String+extension.swift
//  VGSCollectSDK
//
//  Created by Dima on 10.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal extension String {
    var isAlphaNumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
  
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}

internal extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

internal extension String {
	func normalizedHostname() -> String? {

		// Create component.
		guard var component = URLComponents(string: self) else {return nil}

		if component.query != nil {
			// Clear all queries.
			component.query = nil

      let text = "YOUR HOSTNAME HAS QUERIES AND WILL BE NORMALIZED!"
      let event = VGSLogEvent(level: .warning, text: text, severityLevel: .warning)
      VGSCollectLogger.shared.forwardLogEvent(event)
		}

		var path: String
		if let componentHost = component.host {
			// Use hostname if component is url with scheme.
			path = componentHost
		} else {
			// Use path if component has path only.
			path = component.path
		}

		return path.removeExtraPath()
	}

	func removeExtraPath() -> String {
		guard let index = range(of: "/")?.upperBound else {
			return removeLastSlash()
		}

		let substring = String(self.prefix(upTo: index))
		return substring.removeLastSlash()
	}

	func removeLastSlash() -> String {
		var path = self
		if hasSuffix("/") {
			path = String(path.dropLast())
		}

		return path
	}
}
