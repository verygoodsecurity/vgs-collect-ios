//
//  FormTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/17/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class VGSCollectTests: VGSCollectBaseTestCase {
    var collector: VGSCollect!
    
    override func setUp() {
        collector = VGSCollect(id: "tntva5wfdrp")
    }

    override func tearDown() {
        collector = nil
    }

    func testEnvByDefault() {
			let host = collector.apiClient.baseURL?.host ?? ""
        XCTAssertTrue(host.contains("sandbox"))
    }
  
    func testSandboxEnvironmentReturnsTrue() {
      var liveForm = VGSCollect(id: "testID", environment: .sandbox)
			var host = liveForm.apiClient.baseURL?.host ?? ""
      XCTAssertTrue(host == "testID.sandbox.verygoodproxy.com")
    
      liveForm = VGSCollect(id: "testID", environment: .sandbox, dataRegion: "")
			host = liveForm.apiClient.baseURL?.host ?? ""
      XCTAssertTrue(host == "testID.sandbox.verygoodproxy.com")
    
      liveForm = VGSCollect(id: "testID", environment: .sandbox, dataRegion: "ua-0505")
			host = liveForm.apiClient.baseURL?.host ?? ""
      XCTAssertTrue(host == "testID.sandbox-ua-0505.verygoodproxy.com")
    }
    
    func testLiveEnvironmentReturnsTrue() {
      var liveForm = VGSCollect(id: "testID", environment: .live)
			var host = liveForm.apiClient.baseURL?.host ?? ""
      XCTAssertTrue(host == "testID.live.verygoodproxy.com")
    
      liveForm = VGSCollect(id: "testID", environment: .live, dataRegion: "")
			host = liveForm.apiClient.baseURL?.host ?? ""
      XCTAssertTrue(host == "testID.live.verygoodproxy.com")
    
      liveForm = VGSCollect(id: "testID", environment: .live, dataRegion: "ua-0505")
			host = liveForm.apiClient.baseURL?.host ?? ""
      XCTAssertTrue(host == "testID.live-ua-0505.verygoodproxy.com")
    }
  
    func testRegionalEnvironmentReturnsTrue() {
      var liveForm = VGSCollect(id: "testID", environment: "live")
			var host = liveForm.apiClient.baseURL?.host ?? ""
      XCTAssertTrue(host == "testID.live.verygoodproxy.com")
    
      liveForm = VGSCollect(id: "testID", environment: "live-eu1")
			host = liveForm.apiClient.baseURL?.host ?? ""
      XCTAssertTrue(host == "testID.live-eu1.verygoodproxy.com")
    
      liveForm = VGSCollect(id: "testID", environment: "live-ua-0505")
			host = liveForm.apiClient.baseURL?.host ?? ""
      XCTAssertTrue(host == "testID.live-ua-0505.verygoodproxy.com")
      
      var sandboxForm = VGSCollect(id: "testID", environment: "sandbox")
			host = sandboxForm.apiClient.baseURL?.host ?? ""
      XCTAssertTrue(host == "testID.sandbox.verygoodproxy.com")
      
      sandboxForm = VGSCollect(id: "testID", environment: "sandbox-ua5")
			host = sandboxForm.apiClient.baseURL?.host ?? ""
      XCTAssertTrue(host == "testID.sandbox-ua5.verygoodproxy.com")
    
      sandboxForm = VGSCollect(id: "testID", environment: "sandbox-ua-0505")
			host = sandboxForm.apiClient.baseURL?.host ?? ""
      XCTAssertTrue(host == "testID.sandbox-ua-0505.verygoodproxy.com")
    }
  
    func testGenerateRegionalEnvironmentStringReturnsFalse() {
      let notValidEnvStrings = ["liv", "random-ua1", "random-ua-0505",
                                "live-", "live.com", "live/eu",
                                "sandox/us-5050", "sanbox?web=google.com", "", " "]
      
      for env in notValidEnvStrings {
        XCTAssertFalse(VGSCollect.regionalEnironmentStringValid(env))
      }
    }
  
    func testRegionStringValidation() {
      XCTAssertTrue(VGSCollect.regionValid("ua-0505"))
      XCTAssertTrue(VGSCollect.regionValid("ua0505"))
      
      XCTAssertFalse(VGSCollect.regionValid("ua_0505"))
      XCTAssertFalse(VGSCollect.regionValid("ua:0505"))
      XCTAssertFalse(VGSCollect.regionValid("ua-0505/verygoodsecurity.com"))
      XCTAssertFalse(VGSCollect.regionValid("ua-0505?param=val"))
      XCTAssertFalse(VGSCollect.regionValid("ua-0505#val,id=ua-0505&env=1"))
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
    
    func testRegistrationSingleTextField() {
        let config = VGSConfiguration(collector: collector, fieldName: "test")
        let tf = VGSCardTextField()
        tf.configuration = config
        
        XCTAssertTrue(collector.storage.textFields.count == 1)
        XCTAssertTrue(collector.textFields.count == 1)
      
        collector.unregisterTextFields(textField: [tf])
        
        XCTAssertTrue(collector.storage.textFields.count == 0)
        XCTAssertTrue(collector.textFields.count == 0)
    }
  
    func testRegistrationMultipleTextFields() {
      
      let fieldsCount = 5

      collector = VGSCollect(id: "tntva5wfdrp")
      
      for _ in 0..<fieldsCount {
        let config = VGSConfiguration(collector: collector, fieldName: "test")
        let tf = VGSTextField()
        tf.configuration = config
      }
    
      XCTAssertTrue(collector.storage.textFields.count == fieldsCount)
      XCTAssertTrue(collector.textFields.count == fieldsCount)
      
      collector.unregisterTextFields(textField: collector.textFields)
      
      XCTAssertTrue(collector.storage.textFields.count == 0)
      XCTAssertTrue(collector.textFields.count == 0)
  }
  
    func testUnassignSingleTextField() {
        let config = VGSConfiguration(collector: collector, fieldName: "test")
        let tf1 = VGSCardTextField()
        tf1.configuration = config
        
        XCTAssertTrue(collector.storage.textFields.count == 1)
        XCTAssertTrue(collector.textFields.count == 1)
      
        collector.unsubscribeTextField(tf1)
        
        XCTAssertTrue(collector.storage.textFields.count == 0)
        XCTAssertTrue(collector.textFields.count == 0)
      
        collector.unsubscribeTextField(tf1)
        XCTAssertTrue(collector.storage.textFields.count == 0)
        XCTAssertTrue(collector.textFields.count == 0)
    }
  
    func testUnassignMultipleTextFields() {
      let config = VGSConfiguration(collector: collector, fieldName: "test")
      let tf2 = VGSTextField()
      tf2.configuration = config
    
      let tf3 = VGSExpDateTextField()
      tf3.configuration = config
    
      XCTAssertTrue(collector.storage.textFields.count == 2)
      XCTAssertTrue(collector.textFields.count == 2)
      
      collector.unsubscribeTextFields([tf3, tf2])
      XCTAssertTrue(collector.storage.textFields.count == 0)
      XCTAssertTrue(collector.textFields.count == 0)
    }
    
    func testCustomJsonMapping() {
        let cardConfiguration = VGSConfiguration(collector: collector, fieldName: "user.card_data.card_number")
        let cardTextField = VGSCardTextField()
        cardTextField.configuration = cardConfiguration
        cardTextField.textField.secureText = "4111 1111 1111 1112"
        
        let cvcConfiguration = VGSConfiguration(collector: collector, fieldName: "user.card_data.cvc")
        let cvcTextField = VGSTextField()
        cvcTextField.configuration = cvcConfiguration
        cvcTextField.textField.secureText = "123"
        
        let nameConfiguration = VGSConfiguration(collector: collector, fieldName: "user.name")
        let nameTextField = VGSTextField()
        nameTextField.configuration = nameConfiguration
        nameTextField.textField.secureText = "Joe Business"
        
        let ssnConfiguration = VGSConfiguration(collector: collector, fieldName: "ssn")
        let ssnTextField = VGSTextField()
        ssnTextField.configuration = ssnConfiguration
        ssnTextField.textField.secureText = "UA411111111111XZ"
        
        let result = collector.mapStoredInputDataForSubmit(with: nil)
        let expectedResult: [String: Any] = [
            "user": [
                "card_data": [
                    "card_number": "4111 1111 1111 1112",
                    "cvc": "123"
                ],
                "name": "Joe Business"
            ],
            "ssn": "UA411111111111XZ"
        ]
        XCTAssertTrue(expectedResult.jsonStringRepresentation == result.jsonStringRepresentation)
    }
    
    func testCustomJsonMappingWithExtraData() {
        let cardConfiguration = VGSConfiguration(collector: collector, fieldName: "user.card_data.card_number")
        let cardTextField = VGSCardTextField()
        cardTextField.configuration = cardConfiguration
        cardTextField.textField.secureText = "4111 1111 1111 1112"
        
        let cvcConfiguration = VGSConfiguration(collector: collector, fieldName: "user.card_data.cvc")
        let cvcTextField = VGSTextField()
        cvcTextField.configuration = cvcConfiguration
        cvcTextField.textField.secureText = "123"
        
        let nameConfiguration = VGSConfiguration(collector: collector, fieldName: "user.name")
        let nameTextField = VGSTextField()
        nameTextField.configuration = nameConfiguration
        nameTextField.textField.secureText = "Joe Business"
        
        let ssnConfiguration = VGSConfiguration(collector: collector, fieldName: "ssn")
        let ssnTextField = VGSTextField()
        ssnTextField.configuration = ssnConfiguration
        ssnTextField.textField.secureText = "UA411111111111XZ"
        
        let expDateConfiguration = VGSConfiguration(collector: collector, fieldName: "date")
        let expDateTextField = VGSTextField()
        expDateTextField.configuration = expDateConfiguration
        expDateTextField.textField.secureText = "2030-03-30"
        
        let extraData: [String: Any] = [
            "user": [
                "id": 1234567890,
                "name": "unknown"
            ],
            "ssn": "not valid",
            "Date": "05-05-1990"
        ]

        let result = collector.mapStoredInputDataForSubmit(with: extraData)
        
        let expectedResult: [String: Any] = [
            "user": [
                "card_data": [
                    "card_number": "4111 1111 1111 1112",
                    "cvc": "123"
                ],
                "name": "Joe Business",
                "id": 1234567890
            ],
            "ssn": "UA411111111111XZ",
            "date": "2030-03-30",
            "Date": "05-05-1990"
        ]
        XCTAssertTrue(expectedResult.jsonStringRepresentation == result.jsonStringRepresentation)
    }
}
