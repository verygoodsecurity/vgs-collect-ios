//
//  FormTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/17/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework

class FormTests: XCTestCase {
    var form: VGSForm!
    
    override func setUp() {
        form = VGSForm(tnt: "tntva5wfdrp")
    }

    override func tearDown() {
        form = nil
    }

    func testEnvByDefault() {
        let host = form.apiClient.baseURL.host ?? ""
        XCTAssertTrue(host.contains("sandbox"))
    }
    
    func testLiveEnvirinment() {
        let liveForm = VGSForm(tnt: "testID", environment: .live)
        let host = liveForm.apiClient.baseURL.host ?? ""
        XCTAssertTrue(host.contains("live"))
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
    
    func testJail() {
        XCTAssertFalse(VGSForm.isJailbroken())
    }
    
    func testCanOpen() {
        let path = "."
        XCTAssertTrue(VGSForm.canOpen(path: path))
    }
    
    func testRegistrationTextField() {
        let config = VGSConfiguration(form: form, alias: "test")
        let tf = VGSTextField()
        tf.configuration = config
        
        XCTAssertTrue(form.storage.elements.count == 1)
        
        form.unregisterTextFields(textField: [tf])
        
        XCTAssertTrue(form.storage.elements.count == 0)
    }
}
