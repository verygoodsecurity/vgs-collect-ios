//
//  ApiClientTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/19/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class ApiClientTests: XCTestCase {
    var collector: VGSCollect!
    var apiClient: APIClient!
    
    override func setUp() {
        collector = VGSCollect(id: "tntva5wfdrp")
        apiClient = collector.apiClient
        
        let config = VGSConfiguration(collector: collector, fieldName: "cardNumber")
        let cardField = VGSTextField()
        cardField.configuration = config
        
        cardField.textField.secureText = "4111 1111 1111 1111"
    }

    override func tearDown() {
        apiClient = nil
    }
    
    func testSendSimpleData() {
        
        let expectation = XCTestExpectation(description: "Sending data...")
        
        collector.submit0(path: "post") { result  in
            switch result {
            case .success(let code, let data):
                XCTAssertTrue(code == 200)
                XCTAssert(data != nil)
                
            case .failure( _, let error):
                XCTAssertNotNil(error)
                XCTAssertNotNil(error, "Error: \(String(describing: error?.localizedDescription))")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testSendData() {
        
        let expectation = XCTestExpectation(description: "Sending data...")
        
        collector.submit(path: "post") { (data, error) in
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testCustomHeader() {
        let customKey = "sdfhksdfgjsdhfgjh"
        let customHeader = "djfhdkjsfhksdjhgf"
        collector.customHeaders = [
            customKey: customHeader
        ]
        
        let expectation = XCTestExpectation(description: "Sending data...")
        
        collector.submit(path: "post") { (data, error) in
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testErrCase() {
        
        collector.customHeaders = nil
        
        let expectation = XCTestExpectation(description: "Sending wrong data...")
        
        collector.submit(path: "/wrongPath") { (data, _) in
            XCTAssertNil(data)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 60.0)
    }
}
