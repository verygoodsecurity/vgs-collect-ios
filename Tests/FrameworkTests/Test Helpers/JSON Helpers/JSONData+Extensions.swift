//
//  JSONData+Extensions.swift
//  FrameworkTests
//
//  Created on 09.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation
import XCTest
@testable import VGSCollectSDK

internal extension JsonData {

	init?(jsonFileName: String) {
		let notFoundCompletion = {
			print("JSON file \(jsonFileName).json not found or is invalid")
		}

		let bundle = Bundle(for: type(of: VGSCollectTestBundleHelper()))
		#if SWIFT_PACKAGE
			bundle = Bundle.module
		#endif

		if let path = bundle.path(forResource: jsonFileName, ofType: "json") {
			do {
				let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
				let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
				guard let json = jsonResult as? JsonData else {
					notFoundCompletion()
					return nil
				}

				self = json
			} catch {
				notFoundCompletion()
				return nil
			}
		} else {
			notFoundCompletion()
			return nil
		}
	}
}

/// Internal class to identify Test Bundle in non-SPM environment.
internal class VGSCollectTestBundleHelper {}

internal func == (lhs: JsonData, rhs: JsonData ) -> Bool {
		return NSDictionary(dictionary: lhs).isEqual(to: rhs)
}

internal func == (lhs: [JsonData], rhs: [JsonData]) -> Bool {
	let equalElementsCount = lhs.count == rhs.count

	if !equalElementsCount {
		return false
	}

	var isEqual = true
	for index in 0..<rhs.count {
		let value1 = lhs[index]
		let value2 = rhs[index]

		isEqual = value1 == value2
	}

	return isEqual
}
