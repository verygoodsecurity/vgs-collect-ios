//
//  VGSFieldNameSubscriptType.swift
//  VGSCollectSDK
//
//  Created on 09.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Defines subscript logic on how to access object.
internal enum VGSFieldNameSubscriptType: CustomStringConvertible, Equatable {

	/// Index of Array with associated `Int` index.
	case index(Int)

	/// Key with associated `String` key.
	case key(String)

	/// For debug description.
	var description: String {
		switch self {
		case .index(let index):
			return ".index: \(index)"
		case .key(let keyPath):
			return ".key: \(keyPath)"
		}
	}

	/// String representation for key in dot format.
	var dotMapKey: String {
		switch self {
		case .key(let key):
			return key
		case .index(let index):
			return "\(index)"
		}
	}

	/// :nodoc:  Equatable protocol
	static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.key(let key1), .key(let key2)):
			return key1 == key2
		case (.index(let index1), .index(let index2)):
			return index1 == index2
		default:
			return false
		}
	}
}

internal extension Array where Element == VGSFieldNameSubscriptType {

	/// Dot map key. Format `[.key("data"), .key("card_number"), .index(2)]`
	/// to `data.card_number.2`.
	var dotMapNotationKey: String {
		let keys = map({return $0.dotMapKey})
		return keys.joined(separator: ".")
	}
}
