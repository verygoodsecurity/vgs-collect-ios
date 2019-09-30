//
//  FormTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/17/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework

class CollectorTests: XCTestCase {
    var collector: VGSCollect!
    
    override func setUp() {
        collector = VGSCollect(tnt: "tntva5wfdrp")
    }

    override func tearDown() {
        collector = nil
    }

    func testEnvByDefault() {
        let host = collector.apiClient.baseURL.host ?? ""
        XCTAssertTrue(host.contains("sandbox"))
    }
    
    func testLiveEnvirinment() {
        let liveForm = VGSCollect(tnt: "testID", environment: .live)
        let host = liveForm.apiClient.baseURL.host ?? ""
        XCTAssertTrue(host.contains("live"))
    }
    
    func testCustomHeader() {
        let headerKey = "costom-header"
        let headerValue = "custom header value"
        
        collector.customHeaders = [
            headerKey: headerValue
        ]
        
        XCTAssertNotNil(collector.customHeaders)
        XCTAssert(collector.customHeaders![headerKey] == headerValue)
    }
    
    func testJail() {
        XCTAssertFalse(VGSCollect.isJailbroken())
    }
    
    func testCanOpen() {
        let path = "."
        XCTAssertTrue(VGSCollect.canOpen(path: path))
    }
    
    func testRegistrationTextField() {
        let config = VGSConfiguration(collector: collector, fieldName: "test")
        let tf = VGSTextField()
        tf.configuration = config
        
        XCTAssertTrue(collector.storage.elements.count == 1)
        
        collector.unregisterTextFields(textField: [tf])
        
        XCTAssertTrue(collector.storage.elements.count == 0)
    }
}
