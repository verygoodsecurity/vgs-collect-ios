//
//  Collection+Extensions.swift
//  VGSCollectSDK
//
//  Created on 04.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

internal extension Collection {
		/// Returns the element at the specified index if it is within the bounds, otherwise nil.
		subscript (safe index: Index) -> Element? {
				return indices.contains(index) ? self[index] : nil
		}
}
