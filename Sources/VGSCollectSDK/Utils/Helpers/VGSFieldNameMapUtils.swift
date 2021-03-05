//
//  VGSFieldNameMapUtils.swift
//  VGSCollectSDK
//
//  Created on 05.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Utility class to parse field names with `.[1]` notation.
internal final class VGSFieldNameMapUtils {

	// MARK: - Private vars

	private static let indexRegexPattern = "\\[\\d+\\]"

	// MARK: - Public

	static func mapFieldNameToSubscripts(_ fieldName: String) -> [VGSFieldNameSubscriptType] {

		var subscriptors = [VGSFieldNameSubscriptType]()

		// Split key by `.` character.
		fieldName.split(separator: ".").forEach { component in
			let path = String(component)

			// Try to get normal string key before prefix `[`.
			if let keyPathPrefix = path.components(separatedBy: "[").first {
				let subscriptorItem = VGSFieldNameSubscriptType.key(keyPathPrefix)
				subscriptors.append(subscriptorItem)
			}

			// Grab all aray indices: [0].
			let numberPaths = matchesForRegexInText(regex: indexRegexPattern, text: path)

			// Take only first index.
			if let first = numberPaths.first {

				// Take digits index from [0] string.
				let num = first.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")

				// Convert digit index to Int.
				if let numInt = Int(num) {
					print("numInt: \(numInt)")
					let numberSubs = VGSFieldNameSubscriptType.index(numInt)
					subscriptors.append(numberSubs)
				}
			}
		}

		// Return array of subscriptors
		return subscriptors
	}

	static func checkDotOrIndexNotationFormat(in fieldName: String) -> Bool {
		var hasDotNotationOrIndex = false

		if fieldName.contains(".") {
			hasDotNotationOrIndex = true
		}

		if !matchesForRegexInText(regex: indexRegexPattern, text: fieldName).isEmpty {
			hasDotNotationOrIndex = true
		}

		return hasDotNotationOrIndex
	}

	// MARK: - Private

	static func matchesForRegexInText(regex: String, text: String) -> [String] {

			do {
					let regex = try NSRegularExpression(pattern: regex, options: [])
					let nsString = text as NSString
				let results = regex.matches(in: text,
																							options: [], range: NSMakeRange(0, nsString.length))
				return results.map { nsString.substring(with: $0.range)}
			} catch let error as NSError {
					print("invalid regex: \(error.localizedDescription)")
					return []
			}
	}
}

internal extension Array where Element == String {

	/// Check if array of field names has dot notation or array.
	var hasDotNotationFielNames: Bool {
		var hasDotNotation = false
		for key in self {
			if VGSFieldNameMapUtils.checkDotOrIndexNotationFormat(in: key) {
				hasDotNotation = true
				break
			}
		}
		return hasDotNotation
	}
}
