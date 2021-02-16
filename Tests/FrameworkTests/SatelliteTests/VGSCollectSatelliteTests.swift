//
//  VGSCollectSatelliteTests.swift
//  VGSCollectSDK
//
//  Created on 16.02.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class VGSCollectSatelliteTests: XCTestCase {

	/// Test satellite hostname normalization with IP address.
	func testNormalizeSatelliteHostnameForIPAddress() {
		let validNormalizedIPHostname = "192.168.1.5"

		let ipHostnames = ["192.168.1.5", "http://192.168.1.5", "http:192.168.1.5"]

		for index in 0..<ipHostnames.count {
			if let normalized = ipHostnames[index].normalizedHostname() {
				XCTAssert(normalized == validNormalizedIPHostname)
			} else {
				assertionFailure("cannot normalize: \(ipHostnames[index])")
			}
		}
	}

	/// Test satellite hostname normalization with localhost.
	func testNormalizeForLocalHost() {
		let validNormalizedHostname = "localhost"
		let hostnames = ["localhost", "http://localhost", "http:localhost"]

		for index in 0..<hostnames.count {
			if let normalized = hostnames[index].normalizedHostname() {
				XCTAssert(normalized == validNormalizedHostname)
			} else {
				assertionFailure("cannot normalize: \(hostnames[index])")
			}
		}
	}
}
