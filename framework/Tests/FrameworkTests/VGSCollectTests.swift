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
        XCTAssertFalse(VGSCollect.tenantIDValid("tok_123456789"))
        XCTAssertFalse(VGSCollect.tenantIDValid("tok 123456789"))
        XCTAssertFalse(VGSCollect.tenantIDValid("tok@123456789"))
        XCTAssertFalse(VGSCollect.tenantIDValid("token/token"))
        XCTAssertFalse(VGSCollect.tenantIDValid("token:token"))
    }
    
    func testTenantIdValideReturnsTrue() {
        XCTAssertTrue(VGSCollect.tenantIDValid("1234567890"))
        XCTAssertTrue(VGSCollect.tenantIDValid("abcdefghijclmnopqarstuvwxyz"))
        XCTAssertTrue(VGSCollect.tenantIDValid("tok1234567890"))
        XCTAssertTrue(VGSCollect.tenantIDValid("1234567890tok"))
    }
}
