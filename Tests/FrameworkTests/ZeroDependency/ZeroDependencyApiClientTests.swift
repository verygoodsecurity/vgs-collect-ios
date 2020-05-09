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
    var apiClient: APIClient!
    
    override func setUpWithError() throws {
        collector = VGSCollect(id: "tntva5wfdrp", environment: .sandbox)
        apiClient = collector.apiClient
    }

    override func tearDownWithError() throws {
        collector = nil
        apiClient = nil
    }

    func testSendCardForm() {
        let cardNum = "4111111111111111"
        let cardField = VGSTextField(frame: .zero)

        let conf = VGSConfiguration(collector: collector, fieldName: "cardNumber")
        conf.type = .cardNumber

        cardField.configuration = conf
        cardField.textField.secureText = cardNum
        
        let expectation = XCTestExpectation(description: "Sending data...")
        
        collector.submitFieldsData(path: "post") { result in
            switch result {
            case .success(let code, let data):
                XCTAssertTrue(code == 200)
                XCTAssert((data != nil))
                
            case .failure(let code, let error):
                XCTFail("Error: code=\(code):\(String(describing: error?.localizedDescription))")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 60.0)
    }

}
