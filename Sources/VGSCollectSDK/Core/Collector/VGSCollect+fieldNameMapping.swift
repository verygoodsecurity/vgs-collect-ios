//
//  VGSCollect+fieldNameMapping.swift
//  VGSCollectSDK
//
//  Created on 10.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

internal extension VGSCollect {

	/// Map field names from collect to `JsonData`.
	/// - Parameters:
	///   - mergePolicy: `VGSCollectFieldNameMappingPolicy?` object, defines how to map fieldNames. Default is `nil` (no nested Arrays).
	///   - extraData: `JsonData?` object, additional `JSON` for submit data. Default is `nil`.
	/// - Returns: `JsonData` object, data to submit.
	func mapFieldNameToBodyJSON(with mergePolicy: VGSCollectFieldNameMappingPolicy? = nil, extraData: JsonData? = nil) -> JsonData {
		guard let policy = mergePolicy else {
			// Fallback to old implementation if not specified.
			return mapStoredInputDataForSubmit(with: extraData)
		}

		switch policy {
		case .nestedJSON:
			return mapStoredInputDataForSubmit(with: extraData)
		case .nestedJSONWithArray(let mergeArrayPolicy):
			return mapStoredInputDataForSubmitWithArrays(mergeArrayPolicy)
		}
	}

	func mapStoredInputDataForSubmitWithArrays(_ mergeArrayPolicy: VGSCollectArrayMergePolicy, extraData: JsonData? = nil) -> JsonData {
		let collectFieldsJSON: JsonData = VGSFieldNameToJSONDataMapper.provideJSON(for: storage.textFields)

		if let data = extraData {
			let jsonToSubmit = VGSDeepMergeUtils.deepMerge(target: data, source: collectFieldsJSON, mergeArrayPolicy: mergeArrayPolicy)

			return jsonToSubmit
		} else {
			return collectFieldsJSON
		}
	}
}
