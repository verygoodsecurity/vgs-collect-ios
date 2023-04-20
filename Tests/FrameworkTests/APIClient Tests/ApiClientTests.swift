//
//  ApiClientTests.swift
//  FrameworkTests
//

import XCTest
import Combine
@testable import VGSCollectSDK

@available(iOS 13, *)
class ApiClientTests: VGSCollectBaseTestCase {
    var collector: VGSCollect!
  
    var cardTextField: VGSCardTextField!
    var expDateTextField: VGSTextField!
    var cardHolderTextField: VGSTextField!
    var numbersTextField: VGSCardTextField!
  
    let testCardNumber = "41111111111111111"
    let testNumbers = "1234567890"
    let testNumbersResponse = "123-4567-89"
    let testCardHolder = "Joe Business"
    let testExpDate = "1125"
    let testExpDateResponse = "11/2025"
  
    let customHeaderKey = "Customheaderkey"
    let customHeaderValue = "CustomHeaderValue"
    let extraDataKey = "extraKey"
    let extraDataValue = "extraValue"
  
    var cancellables: Set<AnyCancellable>!
  
    override func setUp() {
      collector = VGSCollect(id: MockedDataProvider.shared.vaultId, environment: .sandbox)
      cancellables = Set<AnyCancellable>()
      cardTextField = VGSCardTextField()
      expDateTextField = VGSExpDateTextField()
      cardHolderTextField = VGSTextField()
      numbersTextField = VGSCardTextField()
    }
  
    override func tearDown() {
      collector = nil
      cardTextField = nil
      expDateTextField = nil
      cardHolderTextField = nil
      numbersTextField = nil
    }
  
    func testSendCardToEchoServer() {
        self.configureCardTextFields()
   
      collector.customHeaders = [
          customHeaderKey: customHeaderValue
      ]
     
      let extraData = [extraDataKey: extraDataValue]
    
      let expectation = XCTestExpectation(description: "Sending data...")
        
        collector.sendData(path: "post", method: .post, extraData: extraData) { [weak self] result in
              self?.validateSendDataResponseResults(result)
              expectation.fulfill()
          }
          wait(for: [expectation], timeout: 60.0)
    }
  
  func testAsyncSendCardToEchoServer() {
    self.configureCardTextFields()
    collector.customHeaders = [
        customHeaderKey: customHeaderValue
    ]
    let extraData = [extraDataKey: extraDataValue]

    let expectation = XCTestExpectation(description: "Sending data...")
    Task {
      let result = try await collector.sendData(path: "post", method: .post, extraData: extraData)
      self.validateSendDataResponseResults(result)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 60.0)
  }
  
  func testCardSendPublisherToEchoServer() {
    self.configureCardTextFields()
    collector.customHeaders = [
        customHeaderKey: customHeaderValue
    ]
    let extraData = [extraDataKey: extraDataValue]
    let expectation = XCTestExpectation(description: "Sending data...")
    collector.sendDataPublisher(path: "post", method: .post, extraData: extraData)
                .sink {[weak self] result in
                    self?.validateSendDataResponseResults(result)
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
    wait(for: [expectation], timeout: 60)
  }

  func testWrongTanentId() {
    let form = VGSCollect(id: "wrongId")
    let conf = VGSConfiguration(collector: form, fieldName: "cardField")
    conf.type = .cardNumber
    let field = VGSTextField()
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
        let field = VGSTextField()
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
  
  func testValidRouteId() {
    let vaultId = "tnt12345"
    let routeId = UUID().uuidString
    let environment = "sandbox"
    let proxy = "verygoodproxy.com"
    let expectedUrl = URL(string: "https://\(vaultId)-\(routeId).\(environment).\(proxy)")
    // build url
    let url = APIClient.buildVaultURL(tenantId: vaultId, regionalEnvironment: environment, routeId: routeId)
    XCTAssertTrue(url?.absoluteString != nil)
    XCTAssertTrue(url?.absoluteString == expectedUrl?.absoluteString, "-testValidRouteId error, wrong url: \(String(describing: url))")
  }
  
  func testBaseUrlNotChangedAfterRouteIdSet() {
    let routeId = UUID().uuidString
    let baseUrl = collector.apiClient.baseURL
    // dummy field
    let configuration = VGSConfiguration(collector: collector, fieldName: "textfield")
    let textField = VGSTextField()
    textField.configuration = configuration
    
    let expectation = XCTestExpectation(description: "Sending data...")
    collector.sendData(path: "/post", routeId: routeId) { [weak self] _ in
      // check base url not changed and don't include routeid
      let url = self?.collector.apiClient.baseURL
      XCTAssertTrue(baseUrl?.absoluteString == url?.absoluteString, "-testBaseUrlNotChangedAfterRouteIdSet url error: \(String(describing: url))")
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 60.0)
  }

  private func configureCardTextFields() {
      /// this test requires setting proper inbound routs
      let cardNum = testCardNumber
      let cardConfig = VGSConfiguration(collector: collector, fieldName: "cardNumber")
      cardConfig.type = .cardNumber
      cardTextField.configuration = cardConfig
      cardTextField.textField.secureText = cardNum
    
      let someNumber = testNumbers
      let someNumberConfig = VGSConfiguration(collector: collector, fieldName: "not_secured_some_number")
      someNumberConfig.type = .none
      someNumberConfig.divider = "-"
      someNumberConfig.formatPattern = "### #### ##"
      numbersTextField.configuration = someNumberConfig
      numbersTextField.textField.secureText = someNumber
    
      let expDate = testExpDate
      let expDateConfig = VGSConfiguration(collector: collector, fieldName: "expDate")
      expDateConfig.type = .expDate
      expDateTextField.configuration = expDateConfig
      expDateTextField.textField.secureText = expDate
    
      let cardHolder = testCardHolder
      let cardHolderConfig = VGSConfiguration(collector: collector, fieldName: "not_secured_cardHolder")
      cardHolderConfig.type = .cardHolderName
      cardHolderTextField.configuration = cardHolderConfig
      cardHolderTextField.textField.secureText = cardHolder
  }
  
  private func validateSendDataResponseResults(_ result: VGSResponse) {
    switch result {
    case .success(let code, let data, let response):
      XCTAssertTrue(code == 200)
      XCTAssertNotNil(data)
      XCTAssertNotNil(response)
      
      guard let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
          XCTFail("Error: code=\(code): wrong data format")
          return
      }
      
      if let json = jsonData["json"] as? [String: String] {
        XCTAssertTrue(json[extraDataKey] == extraDataValue)
        XCTAssertNotNil(json["cardNumber"])
        XCTAssertTrue(json["cardNumber"] != testCardNumber)
        XCTAssertTrue(json["expDate"] != testExpDateResponse)
        XCTAssertTrue(json["not_secured_cardHolder"] == testCardHolder)
        XCTAssertTrue(json["not_secured_some_number"] == testNumbersResponse)
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
  }
}
