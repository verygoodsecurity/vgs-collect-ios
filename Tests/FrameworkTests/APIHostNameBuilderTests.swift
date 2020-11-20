//
//  APIHostNameBuilderTests.swift
//  VGSCollectSDK
//
//  Created by Eugene on 20.11.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
import XCTest
@testable import VGSCollectSDK

class APIHostNameBuilderTests: XCTestCase {
	func testBuildHostURL() {
		let validURL = URL(string: "https://js.verygoodvault.com/collect-configs/ios-testing.testhost.io__123456.txt")!

		let testTenantId = "123456"

		guard let url1 = APIHostNameBuilder.buildHostValidationURL(with: "https://ios-testing.testhost.io", tenantId: testTenantId) else {
			assertionFailure("Failed. Cannot build URL with https://")
			return
		}

		guard let url2 = APIHostNameBuilder.buildHostValidationURL(with: "ios-testing.testhost.io", tenantId: testTenantId) else {
			assertionFailure("Failed. Cannot build URL with https://")
			return
		}

		XCTAssertTrue(url1 == validURL)
		XCTAssertTrue(url2 == validURL)
	}
}
