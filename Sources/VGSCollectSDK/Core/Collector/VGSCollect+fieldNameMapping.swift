//
//  VGSCollect+fieldNameMapping.swift
//  VGSCollectSDK
//
//  Created on 10.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

internal extension VGSCollect {

  // MARK: - Request body mappers for VGSCollect.sendData(:)
  
	/// Map fields data to `JsonData`.
	/// - Parameters:
	///   - mergePolicy: `VGSCollectFieldNameMappingPolicy` object, defines how to map fieldNames.
	///   - extraData: `JsonData?` object, additional `JSON` for submit data. Default is `nil`.
	/// - Returns: `JsonData` object, data to submit.
	func mapFieldsToBodyJSON(with mergePolicy: VGSCollectFieldNameMappingPolicy, extraData: JsonData?) -> JsonData {

		switch mergePolicy {
		case .flatJSON:
			return VGSCollect.mapStoredInpuToFlatJSON(with: extraData, from: storage.textFields)
		case .nestedJSON:
			return mapStoredInputDataForSubmit(with: extraData)
		case .nestedJSONWithArrayMerge:
			return VGSCollect.mapStoredInputDataForSubmitWithArrays(fields: storage.textFields, mergeArrayPolicy: .merge, extraData: extraData)
		case .nestedJSONWithArrayOverwrite:
			return VGSCollect.mapStoredInputDataForSubmitWithArrays(fields: storage.textFields, mergeArrayPolicy: .overwrite, extraData: extraData)
		}
	}

	/// Map stored input to JSON with dot-braces notation for nested JSONs and Arrays.
	/// - Parameters:
	///   - mergeArrayPolicy: `VGSCollectArrayMergePolicy` object, merge policy.
	///   - extraData: `JsonData?` object, extra data.
	/// - Returns: `JsonData` to submit.
	static func mapStoredInputDataForSubmitWithArrays(fields: [VGSTextField], mergeArrayPolicy: VGSCollectArrayMergePolicy, extraData: JsonData?) -> JsonData {
		let collectFieldsJSON: JsonData = VGSFieldNameToJSONDataMapper.provideJSON(for: fields)

		if let data = extraData {
			let jsonToSubmit = VGSDeepMergeUtils.deepMerge(target: data, source: collectFieldsJSON, mergeArrayPolicy: mergeArrayPolicy)

			return jsonToSubmit
		} else {
			return collectFieldsJSON
		}
	}
  
  // MARK: - Tokenization Response mappers
  
  /// Map tokenization response body with not tokenized fields values.
  ///  - Parameters:
  ///   - tokenizedData: Data? - tokenization response data.
  ///   - tokenizedFields: [VGSTextField] - fields that should be tokenized
  ///   - notTokenizedFields: [VGSTextField] - fields that should not be tokenized
  /// - Returns: `JsonData` result JSON.
  func buildTokenizationResponseBody(_ tokenizedData: Data?, tokenizedFields: [VGSTextField], notTokenizedFields: [VGSTextField]) -> JsonData? {
    let tokenizedFieldResponse: JsonData? = mapTokenizationResponseDataWithTextField(tokenizedData, textFieds: tokenizedFields)
    let notTokenizedFieldResponse: JsonData? = mapNotTokenazibleFieldsToResponseBody(notTokenizedFields)
      
    switch(tokenizedFieldResponse, notTokenizedFieldResponse) {
    case(.some(let dict1), .some(let dict2)):
      return deepMerge(dict1, dict2)
    case(.some(let dict1), nil):
      return dict1
    case(nil, .some(let dict2)):
      return dict2
    case(nil, nil):
      return nil
    }
  }
  
  /// Map tokenization response result to JsonData, filter result from input values.
  /// - Returns: `JsonData` to submit.
  func mapTokenizationResponseDataWithTextField(_ data: Data?, textFieds: [VGSTextField]) -> JsonData? {
    guard let tokenizedData = data?.serializeToJsonData?["data"] as? [JsonData] else {
      return nil
    }
    // Convert textfields into dict with output value as a key, fieldname as a value.
    let fieldValuesDict = textFieds.reduce(into: JsonData()) { (dict, element) in

      if let serialazable = element.configuration as? VGSFormatSerializableProtocol, serialazable.shouldSerialize  {
        let output = element.getOutputText()
        let resultJSON = serialazable.serialize(output ?? "")

        for json in resultJSON {
          if let value = json.value as? String {
            dict[value] = json.key
          }
        }
      } else {
        if let value = element.getOutputText() {
          dict[value] = element.fieldName
        }
      }
    }
    // Combine fieldValuesDict with textFileds' fildNames, map into dict with fieldName as a key, alias as a value.
    let result: JsonData = tokenizedData.reduce(into: JsonData()) { (dict, element) in
      if let fieldValue = element["value"] as? String,
         let fieldName = fieldValuesDict[fieldValue] as? String,
         let aliases = element["aliases"] as? [JsonData],
         let alias = aliases.first?["alias"] as? String {
        
        dict[fieldName] = alias
      }
    }
    return result
  }
  /// Map  not tokenizable JSON with key reprsent `textField.fieldName` and value is output text.
  /// - Parameters:
  ///   - notTokenazibleFields - an array of VGSTextField that should not be tokenized.
  /// - Returns: `JsonData?` to submit.
  func mapNotTokenazibleFieldsToResponseBody(_ notTokenazibleFields: [VGSTextField]) -> JsonData {
      return notTokenazibleFields.reduce(into: JsonData()) { (dict, element) in
        dict[element.fieldName] = element.getOutputText()
    }
  }
  
  // MARK: - Tokenization Request mappers

  /// Map stored input for tokenizable textfields to JSON.
  /// - Returns: `JsonData` to submit.
  func mapFieldsToTokenizationRequestBodyJSON(_ textFields: [VGSTextField]) -> JsonData {
    var fieldsData = [JsonData]()
    for textField in textFields {
      guard let tokenizationParameters = textField.tokenizationParameters else {
        continue
      }
      var fieldData = tokenizationParameters.mapToJSON()

      let output = textField.getOutputText()

      /// Check if any serialization should be done before data will be send
      if let serialazable = textField.configuration as? VGSFormatSerializableProtocol, serialazable.shouldSerialize {
        let resultJSON = serialazable.serialize(output ?? "")

        for json in resultJSON {
          var fieldData = tokenizationParameters.mapToJSON()
          fieldData["value"] = json.value
          fieldsData.append(fieldData)
        }
      } else {
        fieldData["value"] = output
        fieldsData.append(fieldData)
      }
    }
    return ["data": fieldsData]
  }
}
