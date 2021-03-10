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

/// Defines policy how to merge arrays objects.
public enum VGSCollectArrayMergePolicy {

	/**
	Overwrites the existing array values completely rather than concatenating them.
	Example:

		// Collect JSON:
		{ "array" :
			[
				{ "number" : "4111-1111-1111-1111" }
			]
  	}

		// Extra data JSON:
		{ "array" :
			[
				{ "some_data" : "123" },
				{ "some" : "111" }
			]
		}

		// JSON to submit:
		{ "array" :
			[
				{ "some_data" : "123" }
			]
		}
	*/
	case overwrite

	/**
	Merge arrays content if possible (JSON <==> JSON at the same index).
	Example:

		// Collect JSON:
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
	case merge
}

/// Request options.
public struct VGSCollectRequestOptions {

	/// Defines how to map fieldNames. Default is `.nestedJSON`.
	public var fieldNameMappingPolicy: VGSCollectFieldNameMappingPolicy = .nestedJSONWithArray(.overwrite)
}
