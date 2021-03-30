//
//  VGSFieldNameToJSONDataMapper.swift
//  VGSCollectSDK
//
//  Created on 05.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Helper class to produce JSON from nested key name.
internal final class VGSFieldNameToJSONDataMapper {

	/// Provide `JSON` for array of textFields.
	/// - Parameter textFields: Array of `VGSTextField`.
	/// - Returns: `JsonData` with textFields data.
	internal static func provideJSON(for textFields: [VGSTextField]) -> JsonData {
		var collectFieldsJSON: JsonData = [:]
    
		for field in textFields {
      let fieldName = field.fieldName
      let fieldValue = field.getOutputText()
      
      /// Check if field value need serioalization
      if let serialazable = field.configuration as? VGSFormatSerializableProtocol, serialazable.shouldSerialize {
        let serializationResult = serialazable.serialize(fieldValue ?? "")
        serializationResult.forEach { (componentFieldName, componentValue) in
          VGSFieldNameToJSONDataMapper.mapFieldNameToJSON(componentFieldName, value: componentValue as Any, json: &collectFieldsJSON)
        }
      } else {
        VGSFieldNameToJSONDataMapper.mapFieldNameToJSON(fieldName ?? "", value: fieldValue as Any, json: &collectFieldsJSON)
      }
		}
		return collectFieldsJSON
	}

	/// Map field name to JSON using dot-braces notation.
	/// - Parameters:
	///   - fieldName: String object, should be valid fieldName.
	///   - value: `Any` object, value to set.
	///   - json: `JsonData` object to modify, `inout`.
	internal static func mapFieldNameToJSON(_ fieldName: String, value: Any, json: inout JsonData) {
		setValue(value: value, fieldName: fieldName, dictionary: &json)
	}

  // Take this from https://github.com/tonyli508/ObjectMapperDeep
	// Udate logic for reserving array capacity as JS lib https://github.com/henrytseng/dataobject-parser

	static private func setValue(value: Any, fieldName: String, dictionary: inout JsonData) {
		let subscripts = VGSFieldNameToSubscriptMapper.mapFieldNameToSubscripts(fieldName)
		let components = ArraySlice(subscripts)

		var collection: Any = dictionary as JsonData
		// Because JSONDictionary is a dictionary so root array object won't map properly.
		// For now we assume root object is dictionary.
		if let newDictionary = setValue(value: value, forKeyPathComponents: components, collection: &collection) as? JsonData {
			dictionary = newDictionary
		}
	}

	/**
	Set value for collection
	because casted value doesn't work for inout parameters (address changed), so we need to return the collection
	- parameter value:      value Any
	- parameter components: key components
	- parameter collection: Dictionary or Array
	- returns: Collection with value set
	*/
	static private func setValue(value: Any, forKeyPathComponents components: ArraySlice<VGSFieldNameSubscriptType>, collection: inout Any) -> Any? {
		guard let head = components.first else {
			return nil
		}

		// Convert head to string key.
		let headStringKey = head.dotMapKey

		// If one component => last component, tail of key. Add value, don't create empty JSON/Array.
		if components.count == 1 {
			addValue(value: value, forKey: String(headStringKey), toCollection: &collection)
		} else {

			// Try to get value for head key.
			var child = getValue(forKey: String(headStringKey), fromCollection: collection)

			// Tail of key. Remaining key components.
			let tail = components.dropFirst()

			// Insert empty JSON or Array.
			if child == nil {
				if let firstChildComponentKey = tail.first?.dotMapKey {
					// Check the first child component key, if it's unsigned integer then child is array type.
					if UInt(firstChildComponentKey) != nil {
						// empty array
						child = [] as Any
					} else {
						// empty dictionary
						child = [:] as Any
					}
				}
			}

			child = setValue(value: value, forKeyPathComponents: tail, collection: &child!)

			// Add child to collection
			addValue(value: child!, forKey: String(headStringKey), toCollection: &collection)
		}

		// return collection value, inout not works for casted type (as Dictionary and Array are structures)
		return collection
	}

	/**
	Get value from Dictionary or Array
	- parameter key:		key String
	- parameter collection: Dictionary or Array
	- returns: child value or nil
	*/
	static private func getValue(forKey key: String, fromCollection collection: Any) -> Any? {

		if let dictionary = collection as? JsonData {
			return dictionary[key]
		} else if let array = collection as? [Any?], let index = Int(key), array.count > index {
			let item = array[index]
			return item
		}

		return nil
	}

	/**
	Add child value key pair to Dictionary or append value to Array
	- parameter value:      child value Any
	- parameter key:        key String
	- parameter collection: Dictionary or Array
	*/
	static private func addValue(value: Any, forKey key: String, toCollection collection: inout Any) {

		if var dictionary = collection as? JsonData {
			// Add key value pair.
			dictionary[key] = value
			collection = dictionary as Any
		} else if var array = collection as? [Any?] {
			if let index = Int(key) {
				if index < array.count {
					// Array has valid capacity. Just update value for index.
					array[index] = value
				} else {
					// Fill array with nil to align index with required capacity. The same behavior of https://github.com/henrytseng/dataobject-parser on JS

					let newCount = index

					// Append nils to align old array with new capacity.
					while array.count < newCount {
						array.append(nil)
					}

					// Append last.
					array.append(value)
				}
			} else {
				// Do nothing since, Array index is invalid.
			}

			collection = array as Any
		}
	}
}
