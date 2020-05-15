//
//  ZeroDependencyApiClientTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 09.05.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class ZeroDependencyApiClientTests: XCTestCase {

    var collector: VGSCollect!
    
    override func setUp() {
        collector = VGSCollect(id: "tntva5wfdrp", environment: .sandbox)
    }

    override func tearDown() {
        collector = nil
    }

    func testSendCardForm() {
        let cardNum = "4111111111111111"
        let conf = VGSConfiguration(collector: collector, fieldName: "cardNumber")
        conf.type = .cardNumber
        let field = VGSTextField(frame: .zero)
        field.configuration = conf
        field.textField.secureText = cardNum
        
        let expectation = XCTestExpectation(description: "Sending data...")
        
        collector.sendData(path: "post") { result in
            switch result {
            case .success(let code, let data, _):
                XCTAssertTrue(code == 200)
                XCTAssert((data != nil))
                
            case .failure(let code, _, _, let error):
                XCTFail("Error: code=\(code):\(String(describing: error?.localizedDescription))")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }

    func testWrongTanentId() {
        let form = VGSCollect(id: "wrongId")
        let conf = VGSConfiguration(collector: form, fieldName: "cardField")
        conf.type = .cardNumber
        let field = VGSTextField(frame: .zero)
        field.configuration = conf
        field.textField.secureText = "5252"
        
        let expectation = XCTestExpectation(description: "Sending data...")
        
        form.sendData(path: "post") { result in
            switch result {
            case .success:
                break
                
            case .failure(let code, let data, _, _):
                XCTAssertNotNil(data)
                XCTAssertTrue(code >= 400)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
    
    func testWrongPath() {
        let conf = VGSConfiguration(collector: collector, fieldName: "cardField")
        conf.type = .cardNumber
        let field = VGSTextField(frame: .zero)
        field.configuration = conf
        field.textField.secureText = "5252"
        
        let expectation = XCTestExpectation(description: "Sending data...")
        
        collector.sendData(path: "wrongPath") { result in
            switch result {
            case .success:
                break
                
            case .failure(let code, let data, _, _):
                XCTAssertNotNil(data)
                XCTAssertTrue(code >= 400)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
}
