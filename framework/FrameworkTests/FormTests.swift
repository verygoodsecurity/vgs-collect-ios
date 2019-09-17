//
//  FormTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/17/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
import VGSFramework

class FormTests: XCTestCase {
    var form: VGSForm!
    
    override func setUp() {
        form = VGSForm(tnt: "tntva5wfdrp")
    }

    override func tearDown() {
        form = nil
    }

    func testEnvByDefault() {
        XCTAssertNotNil(form)
    }
    
    func testSandboxEnvirinment() {
    }
    
    func testCustomHeader() {
        let headerKey = "costom-header"
        let headerValue = "custom header value"
        
        form.customHeaders = [
            headerKey: headerValue
        ]
        
        XCTAssertNotNil(form.customHeaders)
        XCTAssert(form.customHeaders![headerKey] == headerValue)
    }
}
