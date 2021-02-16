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
		let hostnames = ["localhost", "http://localhost", "http:localhost", "http://localhost/database/users?id=1"]

		for index in 0..<hostnames.count {
			if let normalized = hostnames[index].normalizedHostname() {
				XCTAssert(normalized == validNormalizedHostname)
			} else {
				assertionFailure("cannot normalize: \(hostnames[index])")
			}
		}
	}

	/// Test port validation.
	func testPortValidation() {
		let validPorts = [1, 2, 3, 88, 9098, 80, 1000]
		let invalidPorts = [-1, 0, 100000000, 1000000000]

		for index in 0..<validPorts.count {
			XCTAssertTrue(VGSCollectSatelliteUtils.isSatellitePortValid(validPorts[index]), "*\(validPorts[index]) is valid port.*")
		}

		for index in 0..<invalidPorts.count {
			XCTAssertFalse(VGSCollectSatelliteUtils.isSatellitePortValid(invalidPorts[index]), "*\(invalidPorts[index]) is invalid port.*")
		}
	}

	/// Test satellite hostname validation.
	func testSatelliteValidHostnames() {
		let validhostnames = ["localhost", "http://localhost", "http:localhost", "192.168.1", "192.168.1.3", "192.168.1.5", "http://192.168.1.3"]

		for index in 0..<validhostnames.count {
			XCTAssertTrue(VGSCollectSatelliteUtils.isSatelliteHostnameValid(validhostnames[index]), "*\(validhostnames[index]) is valid hostname.*")
		}
	}

	/// Test invalid hostnames.
	func testSatelliteInvalidHostnames() {
		let invalidhostnames = ["google", "http://google.com", "http://localhostsomebackend", "193.168.1", "192.169.1.3", "192.170.1.5", "http://190.168.1.3"]

		for index in 0..<invalidhostnames.count {
			XCTAssertFalse(VGSCollectSatelliteUtils.isSatelliteHostnameValid(invalidhostnames[index]), "*\(invalidhostnames[index]) is invalid hostname.*")
		}
	}
}
