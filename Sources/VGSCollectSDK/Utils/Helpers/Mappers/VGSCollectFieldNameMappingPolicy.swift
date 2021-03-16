//
//  VGSCollectFieldNameMappingPolicy.swift
//  VGSCollectSDK
//
//  Created on 10.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Defines fieldName mapping to JSON.
public enum VGSCollectFieldNameMappingPolicy {

	/**
	Map fieldName to nested JSON.
	Example:
	card_data.number => nested JSON

		{
			"card_data" :
				{
					"number" : "4111-1111-1111-1111"
				}
		}
	*/

	case nestedJSON

	/**
	Map field name to nested JSON and array if array index is specified.
	Example:
	card_data[1].number => nested JSON with array

		{
			"card_data" :
				[
					null,

					{ "number" : "4111-1111-1111-1111" }
				]
		}

	Merge arrays content at the same nested level if possible.

				// Collect fields JSON:
				[
				 { "cvc" : "555" }
				]

				// Extra data JSON:
				[
				 { "number" : "4111-1111-1111-1111" }
				]

				// JSON to submit:
				[
				 {
					"cvc" : "555",
					"number" : "4111-1111-1111-1111"
				 }
				]
	*/
	case nestedJSONWithArrayMerge

	/**
	Map field name to nested JSON and array if array index is specified.
	Example:
	card_data[1].number => nested JSON with array

		{
			"card_data" :
				[
					null,

					{ "number" : "4111-1111-1111-1111" }
				]
		}

	Completely overwrite extra data array with Collect Array data.

				// Collect fields JSON:
				[
				 { "cvc" : "555" }
				]

				// Extra data JSON:
				[
				 { "number" : "4111-1111-1111-1111" },
				 { "id" : "1111" }
				]

				// JSON to submit:
				[
				 {
					"cvc" : "555",
				 }
				]
	*/
	case nestedJSONWithArrayOverwrite
}

/// Defines array merge policy.
internal enum VGSCollectArrayMergePolicy {
	///	Merge arrays content at the same level if possible.
	case merge

	/// Completely overwrite extra data array with Collect Array data.
	case overwrite
}

/// Request options.
public struct VGSCollectRequestOptions {

	/// Defines how to map fieldNames to JSON. Default is `.nestedJSON`.
	public var fieldNameMappingPolicy: VGSCollectFieldNameMappingPolicy = .nestedJSON

	/// Initializer.
	/// - Parameter fieldNameMappingPolicy: `VGSCollectFieldNameMappingPolicy` object, default `.nestedJSON`.
	public init(fieldNameMappingPolicy: VGSCollectFieldNameMappingPolicy = .nestedJSON) {
		self.fieldNameMappingPolicy = fieldNameMappingPolicy
	}
}
