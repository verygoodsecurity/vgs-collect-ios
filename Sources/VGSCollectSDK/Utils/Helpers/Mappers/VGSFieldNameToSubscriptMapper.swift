//
//  VGSFieldNameToSubscriptMapper.swift
//  VGSCollectSDK
//
//  Created on 05.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Utility class to parse field names with `.[1]` notation.
internal final class VGSFieldNameToSubscriptMapper {

	// MARK: - Private vars

	/// Regex pattern to find array index in format: [1].
	private static let arrayIndexRegexPattern = "\\[\\d+\\]"

	// MARK: - Helpers

	/// Map field name to subscripts.
	/// - Parameter fieldName: `String` object, should be fieldName.
	/// - Returns: `[VGSFieldNameSubscriptType]` object, array of subscripts.
	static func mapFieldNameToSubscripts(_ fieldName: String) -> [VGSFieldNameSubscriptType] {

		var subscripts = [VGSFieldNameSubscriptType]()

		// Split key by `.` character.
		fieldName.split(separator: ".").forEach { component in
			let path = String(component)

			// Try to get normal string key before prefix `[`.
			if let keyPathPrefix = path.components(separatedBy: "[").first {
				let subscriptorItem = VGSFieldNameSubscriptType.key(keyPathPrefix)
				subscripts.append(subscriptorItem)
			} else {
				// Add empty "" JSON key. Each key component should have at least one JSON key. We don't want to produce multiple-dimension arrars.
				// This is required for consistency with https://github.com/henrytseng/dataobject-parser on JS.
				let subscriptorItem = VGSFieldNameSubscriptType.key("")
				subscripts.append(subscriptorItem)
			}

			// Grab all aray indices: [0].
			let numberPaths = matchesForRegexInText(regex: arrayIndexRegexPattern, text: path)

			// Take only first index.
			if let first = numberPaths.first {

				// Take digits index from [0] string.
				let num = first.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")

				// Convert digit index to Int.
				if let numInt = Int(num) {
					let numberSubs = VGSFieldNameSubscriptType.index(numInt)
					subscripts.append(numberSubs)
				}
			}
		}

		// Return array of subscripts.
		return subscripts
	}

	// MARK: - Private

	/// Find all matches for regex pattern in text. Invalid regex will produce empty array.
	/// - Parameters:
	///   - regex: `String` object, valid regex pattern.
	///   - text: `String` object, text to find matches.
	/// - Returns: Array of `String` containing all matches.
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
