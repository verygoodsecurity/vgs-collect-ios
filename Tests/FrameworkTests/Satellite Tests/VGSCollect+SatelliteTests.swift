//
//  VGSCollect+SatelliteTests.swift
//  FrameworkTests
//
//  Created on 17.02.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation
import XCTest
@testable import VGSCollectSDK

class VGSCollectSatelliteTests: VGSCollectBaseTestCase {
	/// Valid tenant ID.
	let tenantID: String = "testID"

	/// Holds satellite test data.
	struct APISatelliteTestData {
		let environment: String
		let hostname: String?
		let port: Int?
		let url: URL
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

	/// Test collect init with valid satellite configuration.
	func testCollectInitWithValidSatelliteConfiguration() {
		let testData = [
			APISatelliteTestData(environment: "sandbox", hostname: "localhost", port: 9908, url: URL(string: "http://localhost:9908")!),

			APISatelliteTestData(environment: "sandbox", hostname: "192.168.0", port: 9908, url: URL(string: "http://192.168.0:9908")!),

			APISatelliteTestData(environment: "sandbox", hostname: "192.168.1.5", port: 9908, url: URL(string: "http://192.168.1.5:9908")!),

			APISatelliteTestData(environment: "sandbox", hostname: "http://192.168.1.5", port: 9908, url: URL(string: "http://192.168.1.5:9908")!)
		]

		for index in 0..<testData.count {
			let config = testData[index]

			let outputText = "index: \(index) collect satellite configuration with environment: \(config.environment) hostname: \(config.hostname ?? "*nil*") port: \(config.port!) should produce satellite collect: \(config.url)"

			// Test init with enum.
			let collect1 = VGSCollect(id: tenantID, environment: .sandbox, hostname: config.hostname, satellitePort: config.port)

			XCTAssertTrue(collect1.formAnalyticsDetails.isSatelliteMode == true, "\(outputText) should produce *satellite* mode in analytics")

			let url1 = collect1.apiClient.baseURL?.absoluteString ?? ""
			XCTAssertTrue(url1 == config.url.absoluteString, outputText)

			// Test init with String environment.
			let collect2 = VGSCollect(id: tenantID, environment: config.environment, hostname: config.hostname, satellitePort: config.port)

			XCTAssertTrue(collect2.formAnalyticsDetails.isSatelliteMode == true, "\(outputText) should produce *satellite* mode in analytics")

			let url2 = collect2.apiClient.baseURL?.absoluteString ?? ""
			XCTAssertTrue(url2 == config.url.absoluteString, outputText)
		}
	}

	/// Test collect init with invalid satellite configuration.
	func testCollectInitWithInvalidSatelliteConfiguration() {
		let testData = [
			APISatelliteTestData(environment: "live", hostname: "localhost", port: 9908, url: URL(string: "https://testID.live.verygoodproxy.com")!),

			APISatelliteTestData(environment: "live", hostname: "192.168.0", port: 9908, url: URL(string: "https://testID.live.verygoodproxy.com")!),

			APISatelliteTestData(environment: "live", hostname: nil, port: 9908, url: URL(string: "https://testID.live.verygoodproxy.com")!),

			APISatelliteTestData(environment: "live", hostname: nil, port: nil, url: URL(string: "https://testID.live.verygoodproxy.com")!),

			APISatelliteTestData(environment: "live", hostname: "http://192.168.1.5", port: 9908, url: URL(string: "https://testID.live.verygoodproxy.com")!)
		]

		for index in 0..<testData.count {
			let config = testData[index]
			var portText = "nil"
			if let port = config.port {
				portText = "\(port)"
			}

			let outputText = "index: \(index) collect satellite INVALID configuration with environment: \(config.environment) hostname: \(config.hostname ?? "*nil*") port: \(portText) should produce normal vault collect URL: \(config.url)"

			// Test init with enum.
			let collect1 = VGSCollect(id: tenantID, environment: .live, hostname: config.hostname, satellitePort: config.port)

			XCTAssertTrue(collect1.formAnalyticsDetails.isSatelliteMode == false, "\(outputText) should NOT produce *satellite* mode in analytics")

			let url1 = collect1.apiClient.baseURL?.absoluteString ?? ""
			XCTAssertTrue(url1 == config.url.absoluteString, "\(outputText) - produced: \(url1)")

			// Test init with String environment.
			let collect2 = VGSCollect(id: tenantID, environment: config.environment, hostname: config.hostname, satellitePort: config.port)

			XCTAssertTrue(collect2.formAnalyticsDetails.isSatelliteMode == false, "\(outputText) should NOT produce *satellite* mode in analytics")

			let url2 = collect2.apiClient.baseURL?.absoluteString ?? ""
			XCTAssertTrue(url2 == config.url.absoluteString, "\(outputText) - produced: \(url2)")
		}
	}
}
