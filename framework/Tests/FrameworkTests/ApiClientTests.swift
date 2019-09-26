//
//  ApiClientTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/19/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework

class ApiClientTests: XCTestCase {
    var form: VGSForm!
    var apiClient: APIClient!
    
    override func setUp() {
        form = VGSForm(tnt: "tntva5wfdrp")
        apiClient = form.apiClient
        
        let config = VGSConfiguration(form: form, alias: "cardNumber")
        let cardField = VGSTextField()
        cardField.configuration = config
        
        cardField.textField.text = "4111 1111 1111 1111"
    }

    override func tearDown() {
        apiClient = nil
    }
    
    func testSendData() {
        
        let expectation = XCTestExpectation(description: "Sending data...")
        
        form.sendData(path: "post") { (data, error) in 
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
