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
    var collector: VGSCollect!
    var apiClient: APIClient!
    
    override func setUp() {
        collector = VGSCollect(id: "tntva5wfdrp")
        apiClient = collector.apiClient
        
        let config = VGSConfiguration(collector: collector, fieldName: "cardNumber")
        let cardField = VGSTextField()
        cardField.configuration = config
        
        cardField.textField.text = "4111 1111 1111 1111"
    }

    override func tearDown() {
        apiClient = nil
    }
    
    func testSendData() {
        
        let expectation = XCTestExpectation(description: "Sending data...")
        
        collector.sendData(path: "post") { (data, error) in 
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
