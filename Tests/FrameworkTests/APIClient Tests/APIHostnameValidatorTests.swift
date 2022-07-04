//
//  APIHostnameValidatorTests.swift
//  VGSCollectSDK
//
//  Created by Eugene on 20.11.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
import XCTest
@testable import VGSCollectSDK

class APIHostnameValidatorTests: XCTestCase {
	func testBuildHostURL() {
		let validURL = URL(string: "https://js.verygoodvault.com/collect-configs/ios-testing.testhost.io__123456.txt")!

		let validHostnames = [
		"https://ios-testing.testhost.io",
		"ios-testing.testhost.io",
		"http://ios-testing.testhost.io",
		"https://ios-testing.testhost.io/",
		"ios-testing.testhost.io/",
		"http://ios-testing.testhost.io/"
		]

		let testTenantId = "123456"

		validHostnames.forEach { (hostname) in
			if let url = APIHostnameValidator.buildHostValidationURL(with: hostname, tenantId: testTenantId) {
				print("test hostname: \(hostname)")
				XCTAssertTrue(url == validURL)
			} else {
				assertionFailure("Cannot build url with hostname: \(hostname)")
			}
		}
	}

	func testBuildHostURLWithPrefix() {
		let validURL = URL(string: "https://js.verygoodvault.com/collect-configs/www.ios-testing.testhost.io__123456.txt")!

		let validHostnames = [
		"https://www.ios-testing.testhost.io",
		"www.ios-testing.testhost.io",
		"http://www.ios-testing.testhost.io",
		"https://www.ios-testing.testhost.io/",
		"www.ios-testing.testhost.io/",
		"http://www.ios-testing.testhost.io/"
		]

		let testTenantId = "123456"

		validHostnames.forEach { (hostname) in
			if let url = APIHostnameValidator.buildHostValidationURL(with: hostname, tenantId: testTenantId) {
				print("test hostname: \(hostname)")
				XCTAssertTrue(url == validURL)
			} else {
				assertionFailure("Cannot build url with hostname: \(hostname)")
			}
		}
	}

	func testBuildHostURLWithQueries() {
		let validURL = URL(string: "https://js.verygoodvault.com/collect-configs/www.ios-testing.testhost.io__123456.txt")!

		let validHostnames = [
		"https://www.ios-testing.testhost.io/search?q=test+dosmth&oq=test+dosmth",
		"www.ios-testing.testhost.io/search?q=test&obj=123",
		"http://www.ios-testing.testhost.io//search?q=test+dosmth&oq=test+dosmth//",
		"www.ios-testing.testhost.io/search?q=test+dosmth&oq=test+dosmth",
		"http://www.ios-testing.testhost.io/search?q=test+dosmth&oq=test+dosmth///"
		]

		let testTenantId = "123456"

		validHostnames.forEach { (hostname) in
			if let url = APIHostnameValidator.buildHostValidationURL(with: hostname, tenantId: testTenantId) {
				print("test hostname: \(hostname)")
				XCTAssertTrue(url == validURL)
			} else {
				assertionFailure("Cannot build url with hostname: \(hostname)")
			}
		}
	}

	func testSecureURL() {
		let secureURL = URL(string: "https://js.verygoodvault.com/collect-configs/ios-testing.testhost.io__123456.txt")!

		let insecureURL = URL(string: "http://js.verygoodvault.com/collect-configs/ios-testing.testhost.io__123456.txt")!

		XCTAssertTrue(secureURL.hasSecureScheme())
		XCTAssertFalse(insecureURL.hasSecureScheme())

		guard let updatedURL = URL.urlWithSecureScheme(from: insecureURL) else {
			assertionFailure("Failed. Cannot change URL scheme from \(insecureURL)")
			return
		}

		XCTAssertTrue(secureURL == updatedURL)
	}
}
