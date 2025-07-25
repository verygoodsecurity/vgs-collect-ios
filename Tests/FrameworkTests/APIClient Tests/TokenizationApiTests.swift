//
//  TokenizationApiTests.swift
//  FrameworkTests
//

import XCTest
import Combine
@testable import VGSCollectSDK

@MainActor
class TokenizationApiTests: VGSCollectBaseTestCase {
    var collector: VGSCollect!
  
    var cardTextField: VGSCardTextField!
    var expDateTextField: VGSTextField!
    var cvcTextField: VGSCVCTextField!
    var cardHolderTextField: VGSTextField!
    var numbersTextField: VGSCardTextField!

    let testCardNumber = "41111111111111111"
    let testCVC = "123"
    let testNumbers = "1234567890"
    let testNumbersResponse = "123-4567-89"
    let testCardHolder = "Joe Business"
    let testExpDate = "1125"
    let testExpDateResponse = "11/2025"
  
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
			collector = VGSCollect(id: MockedDataProvider.shared.tokenizationVaultId, environment: .sandbox)
      cancellables = Set<AnyCancellable>()
      cardTextField = VGSCardTextField()
      cvcTextField = VGSCVCTextField()
      expDateTextField = VGSExpDateTextField()
      cardHolderTextField = VGSTextField()
      numbersTextField = VGSCardTextField()
    }
  
    override func tearDown() {
      collector = nil
      cancellables = nil
      cardTextField = nil
      expDateTextField = nil
      cvcTextField = nil
      cardHolderTextField = nil
      numbersTextField = nil
    }

  func testSendCardToTokenizationAPI() {
      configureCardTextFields()
      let expectation = XCTestExpectation(description: "Sending data...")
      collector.tokenizeData { [weak self] result in
            self?.validateTokenizeDataResponseResults(result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60.0)
    }
  
    func testAsyncTokenizeCardToEchoServer() {
      self.configureCardTextFields()
      let expectation = XCTestExpectation(description: "Sending data...")
      Task {
        let result = await collector.tokenizeData()
        self.validateTokenizeDataResponseResults(result)
        expectation.fulfill()
      }
      wait(for: [expectation], timeout: 60)
    }
  
    func testAsyncTokenizeCardURL() {
      let vaultId = MockedDataProvider.shared.tokenizationVaultId
      let routeId = UUID().uuidString.lowercased()
      let environment = "sandbox"
      let proxy = "verygoodproxy.com"
      let path = "tokens"
      let expectedUrl = URL(string: "https://\(vaultId)-\(routeId).\(environment).\(proxy)/\(path)")?.absoluteString
      
      self.configureCardTextFields()
      let expectation = XCTestExpectation(description: "Sending data...")
      Task {
        let result = await collector.tokenizeData(routeId: routeId)
        let responeURL: String?
        switch result {
        case .success(_, _, let response):
          responeURL = response?.url?.absoluteString
        case .failure(_, _, let response, _):
          responeURL = response?.url?.absoluteString
        }
        XCTAssertTrue(expectedUrl == responeURL, "-testAsyncTokenizeCardURL error: wrong resopnseURL \(responeURL)")
        expectation.fulfill()
      }
      wait(for: [expectation], timeout: 60)
    }
    
    func testCardSendPublisherToEchoServer() {
      self.configureCardTextFields()
      let expectation = XCTestExpectation(description: "Sending data...")
      collector.tokenizeDataPublisher()
                  .sink {[weak self] result in
                      self?.validateTokenizeDataResponseResults(result)
                      expectation.fulfill()
                  }
                  .store(in: &cancellables)
              
      wait(for: [expectation], timeout: 60)
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

      collector.tokenizeData { result in
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
  
  private func configureCardTextFields() {
      /// this test requires setting proper inbound routs
      let cardNum = testCardNumber
      let cardConfig = VGSCardNumberTokenizationConfiguration(collector: collector, fieldName: "cardNumber")
      cardConfig.type = .cardNumber
      cardTextField.configuration = cardConfig
      cardTextField.textField.secureText = cardNum
          
      let expDate = testExpDate
      let expDateConfig = VGSExpDateTokenizationConfiguration(collector: collector, fieldName: "expDate")
      expDateConfig.tokenizationParameters.format = VGSVaultAliasFormat.UUID.rawValue
      expDateConfig.inputDateFormat = .shortYear
      expDateConfig.outputDateFormat = .longYear
      expDateTextField.configuration = expDateConfig
      expDateTextField.textField.secureText = expDate
    
      let cvc = testCVC
      let cvcConfig = VGSCVCTokenizationConfiguration(collector: collector, fieldName: "cvc")
      cvcTextField.configuration = cvcConfig
      cvcTextField.textField.secureText = cvc
    
      /// Not Tokenizable fields
      let cardHolder = testCardHolder
      let cardHolderConfig = VGSConfiguration(collector: collector, fieldName: "not_secured_cardHolder")
      cardHolderConfig.type = .cardHolderName
      cardHolderTextField.configuration = cardHolderConfig
      cardHolderTextField.textField.secureText = cardHolder
        
      let someNumber = testNumbers
      let someNumberConfig = VGSConfiguration(collector: collector, fieldName: "not_secured_some_number")
      someNumberConfig.type = .none
      someNumberConfig.divider = "-"
      someNumberConfig.formatPattern = "### #### ##"
      numbersTextField.configuration = someNumberConfig
      numbersTextField.textField.secureText = someNumber
  }
  
  private func validateTokenizeDataResponseResults(_ result: VGSTokenizationResponse) {
    switch result {
    case .success(let code, let jsonData, let response):
      guard let json = jsonData as? [String: String] else {
          XCTFail("Error: code=\(code): wrong data format")
          return
      }
      XCTAssertTrue(code == 200)
      XCTAssertNotNil(jsonData)
      XCTAssertNotNil(response)
      XCTAssertTrue(json["cardNumber"] != testCardNumber)
      XCTAssertTrue(json["cvc"] != testCVC)
      XCTAssertTrue(json["expDate"] != testExpDateResponse)
      XCTAssertTrue(json["not_secured_cardHolder"] == testCardHolder)
      XCTAssertTrue(json["not_secured_some_number"] == testNumbersResponse)
    case .failure(let code, _, _, let error):
        XCTFail("Error: code=\(code):\(String(describing: error?.localizedDescription))")
    }
  }
}
