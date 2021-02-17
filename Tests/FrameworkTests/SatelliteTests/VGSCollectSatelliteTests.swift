//
//  VGSCollectSatelliteTests.swift
//  VGSCollectSDK
//
//  Created on 16.02.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

/// Test satellite feature.
class VGSCollectSatelliteTests: XCTestCase {

	/// Holds satellite test data.
	struct SatelliteTestData {
	 let hostname: String
	 let port: Int
	 let satelliteURL: URL?
	}

	/// Set up satellite tests.
	override class func setUp() {
		super.setUp()

		// Disable satellite assetions for unit tests.
		VGSCollectSatelliteUtils.isAssertionsEnabled = false
	}

	/// Tear down flow.
	override class func tearDown() {
		super.tearDown()

		// Enable satellite assertions.
		VGSCollectSatelliteUtils.isAssertionsEnabled = true
	}

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

	/// Test build satelite URL function.
	func testBuildSatelliteURL() {

		let testData: [SatelliteTestData] = [
			SatelliteTestData(hostname: "localhost", port: 9098, satelliteURL: URL(string: "http://localhost:9098")!),

			SatelliteTestData(hostname: "http://localhost", port: 9098, satelliteURL: URL(string: "http://localhost:9098")!),

			// *Hostname will be nornalized.
			SatelliteTestData(hostname: "http://localhost/backend", port: 9098, satelliteURL: URL(string: "http://localhost:9098")!),

			SatelliteTestData(hostname: "192.168.0", port: 9098, satelliteURL: URL(string: "http://192.168.0:9098")!),

			SatelliteTestData(hostname: "192.168.1", port: 9098, satelliteURL: URL(string: "http://192.168.1:9098")!),

			SatelliteTestData(hostname: "192.168.1.5", port: 9098, satelliteURL: URL(string: "http://192.168.1.5:9098")!),

			SatelliteTestData(hostname: "http://192.168.0", port: 9098, satelliteURL: URL(string: "http://192.168.0:9098")!),

			SatelliteTestData(hostname: "http://192.168.1", port: 9098, satelliteURL: URL(string: "http://192.168.1:9098")!),

			SatelliteTestData(hostname: "http://192.168.1.5", port: 9098, satelliteURL: URL(string: "http://192.168.1.5:9098")!),

			SatelliteTestData(hostname: "http:192.168.1.5", port: 9098, satelliteURL: URL(string: "http://192.168.1.5:9098")!)
		]

		for index in 0..<testData.count {
			let config = testData[index]
			let outputText = "index: \(index) satellite configuration with hostname: \(config.hostname) port: \(config.port) should produce: \(config.satelliteURL!)"
			if let url = VGSCollectSatelliteUtils.buildSatelliteURL(with: "sandbox", hostname: config.hostname, satellitePort: config.port) {
				XCTAssertTrue(url == config.satelliteURL!, "error: \(url) != \(config.satelliteURL!) - " + outputText)
			} else {
				assertionFailure(outputText)
			}
		}
	}

	/// Test invalid configurations: wrong hostname or port name.
	func testInvalidSatelliteConfiguration() {

		let testData: [SatelliteTestData] = [
			SatelliteTestData(hostname: "localhost", port: -5, satelliteURL: nil),

			SatelliteTestData(hostname: "http://localhostbackend", port: 9098, satelliteURL: nil),

			SatelliteTestData(hostname: "", port: 9098, satelliteURL: nil),

			SatelliteTestData(hostname: "192.168.0", port: 0, satelliteURL: nil),

			SatelliteTestData(hostname: "193.168.1", port: 9098, satelliteURL: nil),

			SatelliteTestData(hostname: "192.168.1.5-backend", port: 9098, satelliteURL: nil),

			SatelliteTestData(hostname: "http://193.168.0", port: 9098, satelliteURL: nil),

			SatelliteTestData(hostname: "http://192.167.1", port: 9098, satelliteURL: nil),

			SatelliteTestData(hostname: "http://localhost192.168.1.5", port: 9098, satelliteURL: nil),

			SatelliteTestData(hostname: "custombackend", port: 9098, satelliteURL: nil),

			SatelliteTestData(hostname: "custombackend", port: 0, satelliteURL: nil)
		]

		for index in 0..<testData.count {
			let config = testData[index]
			let invalidURL = VGSCollectSatelliteUtils.buildSatelliteURL(with: "sandbox", hostname: config.hostname, satellitePort: config.port)
			let outputText = "index: \(index) satellite invalid configuration with hostname: \(config.hostname) port: \(config.port) should produce *nil*, actuallResult: \(invalidURL?.absoluteString ?? "*nil*")"
			XCTAssertTrue(invalidURL == nil, outputText)
		}
	}

	/// Test satellite ignores all non-sandbox environments.
	func testSatelliteEnvironment() {
		let configuration = SatelliteTestData(hostname: "localhost", port: 9098, satelliteURL: URL(string: "http://localhost:9098")!)

		let testData = [
			"live",
			"live-eu",
			"eu-123",
			"us-777"
		]

		for index in 0..<testData.count {
			let environment = testData[index]
			let outputText = "index: \(index) satellite invalid environment: \(environment) but valid hostname: \(configuration.hostname) port: \(configuration.port) should produce *nil*"
			let invalidURL = VGSCollectSatelliteUtils.buildSatelliteURL(with: environment, hostname: configuration.hostname, satellitePort: configuration.port)
			XCTAssertTrue(invalidURL == nil, outputText)
		}
	}

	/// Test satellite IP has correct format.
	func testSatelliteIPCorrectFormat() {

		let validTestIPs = [
			"192.168.1",
			"192.168.1.3",
			"192.168.1.5",
			"192.168.0"
		]

		for index in 0..<validTestIPs.count {
			let ip = validTestIPs[index]
			let outputText = "index: \(index) satellite ip: \(ip) should be valid"
			XCTAssertTrue(VGSCollectSatelliteUtils.verifyIPHostNameIsCorrect(ip), outputText)
		}

		let invalidTestIPs = [
			"192.168.1-localhost",
			"192.168.1.3.backend",
			"192.168.1.5&&&",
			"192.168.0?="
		]

		for index in 0..<invalidTestIPs.count {
			let ip = invalidTestIPs[index]
			let outputText = "index: \(index) satellite ip: \(ip) should be invalid"
			XCTAssertFalse(VGSCollectSatelliteUtils.verifyIPHostNameIsCorrect(ip), outputText)
		}
	}
}
