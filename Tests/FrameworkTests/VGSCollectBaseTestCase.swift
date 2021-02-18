//
//  VGSCollectBaseTestCase.swift
//  FrameworkTests
//
//  Created on 17.02.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation
import XCTest
@testable import VGSCollectSDK

/// Base VGSCollect test case for common setup.
class VGSCollectBaseTestCase: XCTestCase {

	/// Setup collect before tests.
	override class func setUp() {
		super.setUp()

		// Disable analytics in unit tests.
		VGSAnalyticsClient.shared.shouldCollectAnalytics = false
	}
}
