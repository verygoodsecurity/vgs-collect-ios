//
//  ApiClientTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/19/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class ApiClientTests: VGSCollectBaseTestCase {
    var collector: VGSCollect!
        
    override func setUp() {
        collector = VGSCollect(id: "tntva5wfdrp", environment: .sandbox)
    }

    func testSendCardToEchoServer() {
        /// this test require setting proper inbound routs
      
        let cardNum = "4111111111111111"
        let cardConfig = VGSConfiguration(collector: collector, fieldName: "cardNumber")
        cardConfig.type = .cardNumber
        let cardTextField = VGSCardTextField(frame: .zero)
        cardTextField.configuration = cardConfig
        cardTextField.textField.secureText = cardNum
      
        let someNumber = "1234567890"
        let someNumberConfig = VGSConfiguration(collector: collector, fieldName: "not_secured_some_number")
        someNumberConfig.type = .none
        someNumberConfig.divider = "-"
        someNumberConfig.formatPattern = "### #### ##"
        let someNumberTextField = VGSCardTextField(frame: .zero)
        someNumberTextField.configuration = someNumberConfig
        someNumberTextField.textField.secureText = someNumber
      
        let expDate = "1122"
        let expDateConfig = VGSConfiguration(collector: collector, fieldName: "expDate")
        expDateConfig.type = .expDate
        let expDatTextField = VGSTextField(frame: .zero)
        expDatTextField.configuration = expDateConfig
        expDatTextField.textField.secureText = expDate
      
        let cardHolder = "Joe Business"
        let cardHolderConfig = VGSConfiguration(collector: collector, fieldName: "not_secured_cardHolder")
        cardHolderConfig.type = .cardHolderName
        let cardHolderTextField = VGSTextField(frame: .zero)
        cardHolderTextField.configuration = cardHolderConfig
        cardHolderTextField.textField.secureText = cardHolder
          
        let customHeaderKey = "Customheaderkey"
        let customHeaderValue = "CustomHeaderValue"
        collector.customHeaders = [
            customHeaderKey: customHeaderValue
        ]
        
        let extraDataKey = "extraKey"
        let extraDataValue = "extraValue"
        let extraData = [extraDataKey: extraDataValue]
      
        let expectation = XCTestExpectation(description: "Sending data...")
        
        collector.sendData(path: "post", method: .post, extraData: extraData) { result in
              switch result {
              case .success(let code, let data, let response):
                XCTAssertTrue(code == 200)
                XCTAssertNotNil(data)
                XCTAssertNotNil(response)
                
                guard let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    XCTFail("Error: code=\(code): wrong data format")
                    expectation.fulfill()
                    return
                }
                
                if let json = jsonData["json"] as? [String: String] {
                  XCTAssertTrue(json[extraDataKey] == extraDataValue)
                  XCTAssertNotNil(json["cardNumber"])
                  XCTAssertTrue(json["cardNumber"] != cardNum)
                  XCTAssertTrue(json["expDate"] != "11/22")
                  XCTAssertTrue(json["not_secured_cardHolder"] == cardHolder)
                  XCTAssertTrue(json["not_secured_some_number"] == "123-4567-89")
                } else {
                  XCTFail("Error: code=\(code): wrong json format")
                }
                
                if let headers = jsonData["headers"] as? [String: String] {
                  XCTAssertTrue(headers[customHeaderKey] == customHeaderValue)
                } else {
                  XCTFail("Error: code=\(code): wrong json format")
                }
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
