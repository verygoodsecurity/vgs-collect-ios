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

class VGSCollectBaseTestCase: XCTestCase {
	override class func setUp() {
		super.setUp()

		VGSAnalyticsClient.shared.shouldCollectAnalytics = false
	}
}
