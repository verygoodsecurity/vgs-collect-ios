//
//  VGSCollectFieldNameMappingPolicy.swift
//  VGSCollectSDK
//
//  Created on 10.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Defines fieldName mapping.
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

	- Parameters:
	- arrayMergePolicy: `VGSCollectArrayMergePolicy`, defines how to merge arrays.
	*/
	case nestedJSONWithArray(_ arrayMergePolicy: VGSCollectArrayMergePolicy)
}

/// Defines array merge policy.
public enum VGSCollectArrayMergePolicy {

	/**
	Concat arrays content.
	Example:

		/// Input:
		[
		 { "cvc" : "555" }
		]

		[
		 { "number" : "4111-1111-1111-1111" }
		]

		/// Output:
		[
		 { "cvc" : "555" },
		 { "number" : "4111-1111-1111-1111" }
		]
	*/
	case concat

	/**
	Concat arrays content.
	Example:

		/// Input:
		[
		 { "cvc" : "555" }
		]

		[
		 { "number" : "4111-1111-1111-1111" }
		]

		/// Output:
		[
		 { "cvc" : "555",
	     "number" : "4111-1111-1111-1111"
		 }
		]

  */
	case deepMerge
}

/// Request options.
public struct VGSCollectRequestOptions {

	/// Defines how to map fieldNames. Default is `.nestedJSON`.
	public var fieldNameMappingPolicy: VGSCollectFieldNameMappingPolicy = .nestedJSON
}
