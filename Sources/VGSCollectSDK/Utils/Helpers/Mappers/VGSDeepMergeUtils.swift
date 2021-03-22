//
//  VGSDeepMergeUtils.swift
//  VGSCollectSDK
//
//  Created on 04.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Utils for deepMerge.
final internal class VGSDeepMergeUtils {

	// MARK: - Helpers

	/// Deep merge JSON objects and arrays.
	/// - Parameters:
	///   - target: `JsonData` object, target to merge.
	///   - source: `JsonData` object, source to merge.
	///   - mergeArrayPolicy: `VGSCollectArrayMergePolicy` object, array merge policy.
	/// - Returns: `JsonData` object, merged data.
	static func deepMerge(target: JsonData, source: JsonData, mergeArrayPolicy: VGSCollectArrayMergePolicy) -> JsonData {

		var result = target
		for (k2, v2) in source {
			// If JSON and JSON, deep merge JSONData recursively.
			if let v1 = result[k2] as? JsonData, let v2 = v2 as? JsonData {
				result[k2] = deepMerge(target: v1, source: v2, mergeArrayPolicy: mergeArrayPolicy)
				// Try to merge Array1 and Array2.
			} else if let array1 = result[k2] as? Array<Any?>, let array2 = v2 as? Array<Any?> {
				switch mergeArrayPolicy {
				case .merge:
					result[k2] = deepArrayMerge(target: array1, source: array2, mergeArrayPolicy: mergeArrayPolicy)
				case .overwrite:
					result[k2] = v2
				}
			} else {
				// Just add value since d1 doesn't have value k2.
				result[k2] = v2
			}
		}
		return result
	}

	/// Deep merge content of arrays of JSON objects.
	/// - Parameters:
	///   - target: `Array<Any>` object, target to merge.
	///   - source: `Array<Any>` object, source to merge.
	///   - mergeArrayPolicy: `VGSCollectArrayMergePolicy` object, array merge policy.
	/// - Returns: `Array<Any>` object, merged arrays.
	static func deepArrayMerge(target: Array<Any?>, source: Array<Any?>, mergeArrayPolicy: VGSCollectArrayMergePolicy) -> Array<Any?> {
		var result = target

		// Iterate through source array.
		for index in 0..<source.count {
			let value2 = source[index]

			// If target array has element at index try to merge.
			if let value1 = target[safe: index] {
				// Try to deepMerge value1 and value2 (JSON & JSON).
				if let data1 = value1 as? JsonData, let data2 = value2 as? JsonData {
					result[index] = deepMerge(target: data1, source: data2, mergeArrayPolicy: mergeArrayPolicy)
				} else {

					let isSourceJSON = isJSON(value2)

					// Source is JSON, but target is not JSON. Overwrite target with source JSON.
					if isSourceJSON {
						result[index] = value2
					} else {
						// Try to keep both values. Append only non-nil since target array iteration not finished.
						appendValueIfNeeded(value2, at: index, array: &result)
					}
				}
			} else {
				// Target doesn't have value at index of source. Add item from source if result is not nil at this index (already append some values from source before). In this way we can save specified array capacity in source.

				// Append all non-nil values.
				appendValueIfNeeded(value2, at: index, array: &result)
			}
		}

		return result
	}

	/// Append value if needed to array.
	/// - Parameters:
	///   - value: `Any?`, value to append.
	///   - index: `Int` object, iteration index.
	///   - array: Array of `Any?`, `inout`.
	private static func appendValueIfNeeded(_ value: Any?, at index: Int, array: inout [Any?]) {
		// Append all non-nil values.
		guard value == nil else {
			array.append(value)
			return
		}

		// Don't append nil if result array has element at this index.
		// We can have this case when new value from source has already been appended on the previous iteration (non JSON source element).
		// So we iterate through all target values but appended some values from source.
		if index > array.count - 1 {
			array.append(value)
		}
	}

	/// Check if value is `JSON`.
	/// - Parameter json: `Any?` value.
	/// - Returns: `true` if JSON.
	private static func isJSON(_ json: Any?) -> Bool {
		return json is JsonData
	}
}
