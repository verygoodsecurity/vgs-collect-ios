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
    let notTokenizedFieldResponse: JsonData? = mapNotTokenizableFieldsToResponseBody(notTokenizedFields)
      
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
    guard let tokenizedDict = mapTokenizationResponseDataToDict(data) else {return nil}
   
    var result = JsonData()
    for textField in textFields {
      guard let tokenizationParameters = textField.tokenizationParameters,
            let output = textField.getOutputText() else {continue}
      /// Check if field serializable and should have different tokens
      if let serializable = textField.configuration as? VGSFormatSerializableProtocol, serializable.shouldSerialize {
        let resultJSON = serializable.serialize(output)
        /// json - {fieldName:fieldValue}
        for json in resultJSON {
          guard let key = json.value as? String,
                let alias = getTokenizedAlias(from: tokenizedDict, key: key, format: tokenizationParameters.format) else {continue}
          result[json.key] = alias
        }
      } else {
        guard let alias = getTokenizedAlias(from: tokenizedDict, key: output, format: tokenizationParameters.format) else {continue}
        result[textField.fieldName] = alias
      }
    }
    return result
  }
  
  /// Get alias for required field with required alias fromat.
  private func getTokenizedAlias(from tokenizedDict: JsonData, key: String, format: String) -> String? {
    guard  let tokenizedField = tokenizedDict[key] as? JsonData,
           let aliases = tokenizedField["aliases"] as? [JsonData] else {return nil}
    
    /// Map aliases array to dict
    let aliasesDict: [String: String] = aliases.reduce(into: [String: String]()) { (dict, element) in
      if let aliasValue = element["alias"] as? String,
         let aliasFormat = element["format"] as? String {
        dict[aliasFormat] = aliasValue
      }
    }
    return aliasesDict[format]
  }
  
  /// Serialize response data and map it to dict: {"outputValue": {tokenizedData}}
  private func mapTokenizationResponseDataToDict(_ data: Data?) -> JsonData? {
    /// Get tokenized data array
    guard let tokenizedData = data?.serializeToJsonData?["data"] as? [JsonData] else { return nil }
    /// Map tokenized array into dict: {"outputValue": {tokenizedData}}
    let tokenizedDict: JsonData = tokenizedData.reduce(into: JsonData()) { (dict, element) in
      if let fieldValue = element["value"] as? String {
        dict[fieldValue] = element
      }
    }
    return tokenizedDict
  }
  
  /// Map  not tokenizable JSON with key reprsent `textField.fieldName` and value is output text.
  /// - Parameters:
  ///   - notTokenizableFields - an array of VGSTextField that should not be tokenized.
  /// - Returns: `JsonData?` to submit.
  func mapNotTokenizableFieldsToResponseBody(_ notTokenizableFields: [VGSTextField]) -> JsonData {
      return notTokenizableFields.reduce(into: JsonData()) { (dict, element) in
        dict[element.fieldName] = element.getOutputText()
    }
  }
  
  // MARK: - Tokenization Request mappers

  /// Map stored input for tokenizable textfields to JSON.
  /// - Returns: `JsonData` to submit.
  func mapFieldsToTokenizationRequestBodyJSON(_ textFields: [VGSTextField]) -> JsonData {
    var fieldsData = [JsonData]()
    for textField in textFields {
      guard let fieldData = mapFieldTokenizationParameters(textField), !fieldData.isEmpty else {
        continue
      }
      fieldsData.append(contentsOf: fieldData)
    }
    return ["data": fieldsData]
  }
  
  /// Map field tokenization parameters required in a fromat required for tokenization request
  private func mapFieldTokenizationParameters(_ textField: VGSTextField) -> [JsonData]? {
    guard let tokenizationParameters = textField.tokenizationParameters else {
      return nil
    }
    var fieldsData = [JsonData]()
    let output = textField.getOutputText()
    /// Check if any serialization should be done
    if let serializable = textField.configuration as? VGSFormatSerializableProtocol, serializable.shouldSerialize {
      let resultJSON = serializable.serialize(output ?? "")
      for json in resultJSON {
        var fieldData = tokenizationParameters.mapToJSON()
        fieldData["value"] = json.value
        fieldsData.append(fieldData)
      }
    } else {
      var fieldData = tokenizationParameters.mapToJSON()
      fieldData["value"] = output
      fieldsData.append(fieldData)
    }
    return fieldsData
  }
}
