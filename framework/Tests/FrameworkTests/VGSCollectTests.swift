//
//  VGSCollectTests.swift
//  FrameworkTests
//
//  Created by Dima on 13.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSFramework

class VGSCollectTests: XCTestCase {
    
    var vgsCollect: VGSCollect?

    override func tearDown() {
        vgsCollect = nil
    }
    
    func testTenantIdValideReturnsFalse() {
        XCTAssertFalse(VGSCollect.tenantIDValid(""))
        XCTAssertFalse(VGSCollect.tenantIDValid(" "))
        XCTAssertFalse(VGSCollect.tenantIDValid("tnt_123456789"))
        XCTAssertFalse(VGSCollect.tenantIDValid("tnt 123456789"))
        XCTAssertFalse(VGSCollect.tenantIDValid("tnt@123456789"))
        XCTAssertFalse(VGSCollect.tenantIDValid("tenant/tenant"))
        XCTAssertFalse(VGSCollect.tenantIDValid("tenant:tenant"))
    }
    
    func testTenantIdValideReturnsTrue() {
        XCTAssertTrue(VGSCollect.tenantIDValid("1234567890"))
        XCTAssertTrue(VGSCollect.tenantIDValid("abcdefghijklmnopqarstuvwxyz"))
        XCTAssertTrue(VGSCollect.tenantIDValid("tnt1234567890"))
        XCTAssertTrue(VGSCollect.tenantIDValid("1234567890tnt"))
    }
}
