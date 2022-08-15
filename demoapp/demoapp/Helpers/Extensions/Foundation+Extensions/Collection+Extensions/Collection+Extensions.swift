//
//  Collection+Extensions.swift
//  demoapp
//

import Foundation

internal extension Collection {
		/// Returns the element at the specified index if it is within the bounds, otherwise nil.
		subscript (safe index: Index) -> Element? {
				return indices.contains(index) ? self[index] : nil
		}
}
