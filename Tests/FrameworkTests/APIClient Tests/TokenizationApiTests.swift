//
//  TokenizationApiTests.swift
//  FrameworkTests
//

import XCTest
@testable import VGSCollectSDK

class TokenizationApiTests: VGSCollectBaseTestCase {
    var collector: VGSCollect!

    override func setUp() {
			collector = VGSCollect(id: MockedDataProvider.shared.tokenizationVaultId, environment: .sandbox)
    }

    func testSendCardToTokenizationAPI() {
        /// this test require setting tokenzation url as upstream host
      
        /// Tokenizable fields
        let cardNum = "4111111111111111"
        let cardConfig = VGSCardNumberTokenizationConfiguration(collector: collector, fieldName: "cardNumber")
        cardConfig.type = .cardNumber
        let cardTextField = VGSCardTextField()
        cardTextField.configuration = cardConfig
        cardTextField.textField.secureText = cardNum
            
        let expDate = "1125"
        let expDateConfig = VGSExpDateTokenizationConfiguration(collector: collector, fieldName: "expDate")
        expDateConfig.tokenizationParameters.format = VGSVaultAliasFormat.UUID.rawValue
        expDateConfig.inputDateFormat = .shortYear
        expDateConfig.outputDateFormat = .longYear
        let expDatTextField = VGSTextField()
        expDatTextField.configuration = expDateConfig
        expDatTextField.textField.secureText = expDate
      
        let cvc = "123"
        let cvcConfig = VGSCVCTokenizationConfiguration(collector: collector, fieldName: "cvc")
        let cvcTextField = VGSCVCTextField()
        cvcTextField.configuration = cvcConfig
        cvcTextField.textField.secureText = cvc
      
        /// Not Tokenizable fields
        let cardHolder = "Joe Business"
        let cardHolderConfig = VGSConfiguration(collector: collector, fieldName: "not_secured_cardHolder")
        cardHolderConfig.type = .cardHolderName
        let cardHolderTextField = VGSTextField()
        cardHolderTextField.configuration = cardHolderConfig
        cardHolderTextField.textField.secureText = cardHolder
          
        let someNumber = "1234567890"
        let someNumberConfig = VGSConfiguration(collector: collector, fieldName: "not_secured_some_number")
        someNumberConfig.type = .none
        someNumberConfig.divider = "-"
        someNumberConfig.formatPattern = "### #### ##"
        let someNumberTextField = VGSCardTextField()
        someNumberTextField.configuration = someNumberConfig
        someNumberTextField.textField.secureText = someNumber
      
        let expectation = XCTestExpectation(description: "Sending data...")
        
        collector.tokenizeData() { result in
              switch result {
              case .success(let code, let jsonData, let response):
                XCTAssertTrue(code == 200)
                XCTAssertNotNil(jsonData)
                XCTAssertNotNil(response)
                
                guard let json = jsonData as? [String: String] else {
                    XCTFail("Error: code=\(code): wrong data format")
                    expectation.fulfill()
                    return
                }
                
                XCTAssertNotNil(json["cardNumber"])
                XCTAssertTrue(json["cardNumber"] != cardNum)
                XCTAssertTrue(json["cvc"] != cvc)
                XCTAssertTrue(json["expDate"] != "11/2025")
                XCTAssertTrue(json["not_secured_cardHolder"] == cardHolder)
                XCTAssertTrue(json["not_secured_some_number"] == "123-4567-89")
              case .failure(let code, _, _, let error):
                  XCTFail("Error: code=\(code):\(String(describing: error?.localizedDescription))")
              }
              expectation.fulfill()
          }
          wait(for: [expectation], timeout: 60.0)
    }

    func testNotTokenizableFieldsTokenization() {
      /// this test require setting tokenzation url as upstream host
    
      /// Fields that should be ignored if not set as tokenized
      let cardNum = "4111111111111111"
      let cardConfig = VGSConfiguration(collector: collector, fieldName: "cardNumber")
      cardConfig.type = .cardNumber
      let cardTextField = VGSCardTextField()
      cardTextField.configuration = cardConfig
      cardTextField.textField.secureText = cardNum
      
      let cvc = "123"
      let cvcConfig = VGSConfiguration(collector: collector, fieldName: "cvc")
      cvcConfig.type = .cvc
      let cvcTextField = VGSTextField()
      cvcTextField.configuration = cvcConfig
      cvcTextField.textField.secureText = cvc
       
      /// Fields that should be ignored in tokenization request but returned in response
      let expDate = "1125"
      let expDateConfig = VGSExpDateConfiguration(collector: collector, fieldName: "expDate")
      
      expDateConfig.inputDateFormat = .shortYear
      expDateConfig.outputDateFormat = .longYear
      let expDatTextField = VGSTextField()
      expDatTextField.configuration = expDateConfig
      expDatTextField.textField.secureText = expDate
    
      /// Not Tokenizable fields
      let cardHolder = "Joe Business"
      let cardHolderConfig = VGSConfiguration(collector: collector, fieldName: "not_secured_cardHolder")
      cardHolderConfig.type = .cardHolderName
      let cardHolderTextField = VGSTextField()
      cardHolderTextField.configuration = cardHolderConfig
      cardHolderTextField.textField.secureText = cardHolder
        
      let someNumber = "1234567890"
      let someNumberConfig = VGSConfiguration(collector: collector, fieldName: "not_secured_some_number")
      someNumberConfig.type = .none
      someNumberConfig.divider = "-"
      someNumberConfig.formatPattern = "### #### ##"
      let someNumberTextField = VGSCardTextField()
      someNumberTextField.configuration = someNumberConfig
      someNumberTextField.textField.secureText = someNumber
    
      let expectation = XCTestExpectation(description: "Sending data...")
      
      collector.tokenizeData() { result in
            switch result {
            case .success(let code, let jsonData, let response):
              guard let json = jsonData as? [String: String] else {
                  XCTFail("Error: code=\(code): wrong data format")
                  expectation.fulfill()
                  return
              }
              XCTAssertTrue(code == 200)
              XCTAssertNotNil(jsonData)
              XCTAssertNil(response)
              XCTAssertNil(json["cardNumber"])
              XCTAssertNil(json["cvc"])
              XCTAssertTrue(json["expDate"] == "11/2025")
              XCTAssertTrue(json["not_secured_cardHolder"] == cardHolder)
              XCTAssertTrue(json["not_secured_some_number"] == "123-4567-89")
            case .failure(let code, _, _, let error):
                XCTFail("Error: code=\(code):\(String(describing: error?.localizedDescription))")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
}
