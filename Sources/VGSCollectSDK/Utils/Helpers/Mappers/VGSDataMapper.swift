//
//  VGSDataMapper.swift
//  VGSCollectSDK
//
//  Created on 05.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Helper class to produce JSON from nested key name.
internal final class VGSFieldNameDataMapper {

	/// JSON to submit produced from dot notation field name.
	private (set) internal var jsonToSubmit: JsonData = [:]

	// MARK: - Initialization

	/// Initialization.
	/// - Parameters:
	///   - fieldName: `String` object in dot notation format.
	///   - value: `Any` value to set.
	internal init(fieldName: String, value: Any) {
		let subscriptors = VGSFieldNameMapUtils.mapFieldNameToSubscripts(fieldName)
		let dotNotationKey = subscriptors.dotMapKey

		setValue(value: value, key: dotNotationKey, dictionary: &jsonToSubmit)
	}

  // Take this from https://github.com/tonyli508/ObjectMapperDeep
	// Udate logic for reserving array capacity as JS lib https://github.com/henrytseng/dataobject-parser

	private func setValue(value: Any, key: String, dictionary: inout JsonData) {
		let keyComponents = ArraySlice(key.split { $0 == "." })

		var collection: Any = dictionary as JsonData
		// because JSONDictionary is a dictionary so root array object won't map properly
		// for now we assume root object is dictionary
		if let newDictionary = setValue(value: value, forKeyPathComponents: keyComponents, collection: &collection) as? JsonData {
			dictionary = newDictionary
		}
	}

	/**
	Set value for collection
	because casted value doesn't work for inout parameters (address changed), so we need to return the collection
	- parameter value:      value AnyObject
	- parameter components: key components
	- parameter collection: Dictionary or Array
	- returns: Collection with value set
	*/
	private func setValue(value: Any, forKeyPathComponents components: ArraySlice<String.SubSequence>, collection: inout Any) -> Any? {
		guard let head = components.first else {
			return nil
		}

		if components.count == 1 {

			addValue(value: value, forKey: String(head), toCollection: &collection)

		} else {

			var child = getValue(forKey: String(head), fromCollection: collection)

			let tail = components.dropFirst()

			if child == nil {

				let firstChildComponentKey = String(tail.first!)

				// Check the first child component key, if it's unsigned integer then child is array type
				if UInt(firstChildComponentKey) != nil {
					// empty array
					child = [] as Any
				} else {
					// empty dictionary
					child = [:] as Any
				}
			}

			child = setValue(value: value, forKeyPathComponents: tail, collection: &child!)

			// add child to collection
			addValue(value: child!, forKey: String(head), toCollection: &collection)
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
	private func getValue(forKey key: String, fromCollection collection: Any) -> Any? {

		if let dictionary = collection as? JsonData {

			return dictionary[key]
		} else if let array = collection as? [Any?], let index = Int(key) {
			return array[safe: index] as Any?
		}

		return nil
	}

	/**
	Add child value key pair to Dictionary or append value to Array
	- parameter value:      child value AnyObject
	- parameter key:        key String
	- parameter collection: Dictionary or Array
	*/
	private func addValue(value: Any, forKey key: String, toCollection collection: inout Any) {

		if var dictionary = collection as? JsonData {
			// Add key value pair.
			dictionary[key] = value
			collection = dictionary as Any
		} else if var array = collection as? [Any?] {
			if let index = Int(key) {
				if index < array.count {
					array[index] = value
				} else {
					// Fill array with nil to align index with capacity. The same behavior of https://github.com/henrytseng/dataobject-parser for JS.
					for _ in 0..<index {
						array.append(nil)
					}
					array.append(value)
				}
			} else {
				// Do nothing since, Array index is invalid.
			}

			collection = array as Any
		}
	}
}
