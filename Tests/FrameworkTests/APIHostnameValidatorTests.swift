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

		let testTenantId = "123456"

		guard let url1 = APIHostnameValidator.buildHostValidationURL(with: "https://ios-testing.testhost.io", tenantId: testTenantId) else {
			assertionFailure("Failed. Cannot build URL with https://")
			return
		}

		guard let url2 = APIHostnameValidator.buildHostValidationURL(with: "ios-testing.testhost.io", tenantId: testTenantId) else {
			assertionFailure("Failed. Cannot build URL without https://")
			return
		}

		XCTAssertTrue(url1 == validURL)
		XCTAssertTrue(url2 == validURL)
	}

	func testSecureURL() {
		let secureURL = URL(string: "https://js.verygoodvault.com/collect-configs/ios-testing.testhost.io__123456.txt")!

		let insecureURL = URL(string: "http://js.verygoodvault.com/collect-configs/ios-testing.testhost.io__123456.txt")!


		XCTAssertTrue(APIHostnameValidator.hasSecureScheme(url: secureURL))
		XCTAssertFalse(APIHostnameValidator.hasSecureScheme(url: insecureURL))

		guard let updatedURL = APIHostnameValidator.urlWithSecureScheme(from: insecureURL) else {
			assertionFailure("Failed. Cannot change URL scheme from \(insecureURL)")
			return
		}

		XCTAssertTrue(secureURL == updatedURL)
	}
}
