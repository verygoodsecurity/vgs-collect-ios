//
//  VGSDeepMergeUtils.swift
//  VGSCollectSDK
//
//  Created on 05.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Utils for deepMerge.
final internal class VGSDeepMergeUtils {

	// MARK: - Public

	/// Deep merge JSON objects and arrays.
	/// - Parameters:
	///   - target: `JsonData` object, target to merge.
	///   - source: `JsonData` object, source to merge.
	///   - deepMergeArray: `Bool` object, if `true` apply deep merge for arrays elements if possible, otherwise concatenate arrays. Default is `false`.
	/// - Returns: `JsonData` object, merged data.
	static func deepMerge(target: JsonData, source: JsonData, deepMergeArray: Bool = false) -> JsonData {
			print("start deep merge loop")
			print("____________________")
			var result = target
			for (k2, v2) in source {

				print("k2: \(k2) v2: \(v2)")
					// If keys match in d1 and d2 and if v2 is also JSONData - deep merge JSONData recursively.
					if let v1 = result[k2] as? JsonData, let v2 = v2 as? JsonData {
							print("k2 \(k2) has both values in target and sources. Try to merge v1: \(v1) and v2 \(v2)")
						result[k2] = deepMerge(target: v1, source: v2, deepMergeArray: deepMergeArray)
						print("____________________")
						// If keys match in d1 and d2 and if v2 is also JSONArray - try to merge JSONArrays.
					} else if let array1 = result[k2] as? JSONArray, let array2 = v2 as? JSONArray {
						print("k2 \(k2) has both arrays in target and sources. Try to merge arrays array1: \(array1) and array2 \(array2)")
						result[k2] = deepArrayMerge(target: array1, source: array2, deepMergeArrays: deepMergeArray)
						print("____________________")
					} else {
						print("for k2: \(k2) use v2: \(v2)")
						// Just add value since d1 doesn't have value k2.
						result[k2] = v2
						print("____________________")
					}

			}
			print("end deep merge loop")
			print("____________________")
			return result
	}

	/// Deep merge content of arrays of JSON objects.
	/// - Parameters:
	///   - target: `JSONArray` object, target to merge.
	///   - source: `JSONArray` object, source to merge.
	///   - deepMergeArrays: `Bool` object, if `true` apply deep merge for arrays elements if possible, otherwise concatenate arrays. Default is `false`.
	/// - Returns: `JSONArray` object, merged arrays.
	static func deepArrayMerge(target: JSONArray, source: JSONArray, deepMergeArrays: Bool = false) -> JSONArray {
	 print("____________________")
	 print("start of array loop")
	 if !deepMergeArrays {
		 print("concatanate arrays")
		 return target + source
	 } else {
		 var result = target
		 for index in 0..<source.count {
			 let value2 = source[index]
			 if let value1 = target[safe: index] {
				 // Try to deepMerge value1 and value2.
				 print("array: try to deep merge value1 :\(value1) and value 2: \(value2)")
				result[index] = deepMerge(target: value1, source: value2, deepMergeArray: deepMergeArrays)
				 print("array: result[index] :\(result[index]) and value 2: \(value2)")
				 print("____________________")
			 } else {
				 print("append new value2: \(value2) to array")
				 // Array1 doesn't have value at index in Array2. Just item from v2.
				 result.append(value2)
				 print("____________________")
			 }
		 }

		 print("end of array loop")
		 print("____________________")
		 return result
	 }
 }
}
