//
//  FormTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/17/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework

class CollectorTests: XCTestCase {
    var collector: VGSCollect!
    
    override func setUp() {
        collector = VGSCollect(id: "tntva5wfdrp")
    }

    override func tearDown() {
        collector = nil
    }

    func testEnvByDefault() {
        let host = collector.apiClient.baseURL.host ?? ""
        XCTAssertTrue(host.contains("sandbox"))
    }
    
    func testLiveEnvirinment() {
        let liveForm = VGSCollect(id: "testID", environment: .live)
        let host = liveForm.apiClient.baseURL.host ?? ""
        XCTAssertTrue(host.contains("live"))
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
    
    func testRegistrationTextField() {
        let config = VGSConfiguration(collector: collector, fieldName: "test")
        let tf = VGSTextField()
        tf.configuration = config
        
        XCTAssertTrue(collector.storage.elements.count == 1)
        
        collector.unregisterTextFields(textField: [tf])
        
        XCTAssertTrue(collector.storage.elements.count == 0)
    }
    
    func testSubmitValidRequiredFieldsReturnsNotNil() {
        let cardConfiguration = VGSConfiguration(collector: collector, fieldName: "cardNumber")
        cardConfiguration.type = .cardNumber
        cardConfiguration.isRequiredValidOnly = true
        
        let cardTextField = VGSCardTextField()
        cardTextField.configuration = cardConfiguration
        cardTextField.textField.text = "4111 1111 1111 1111"
        
        let nameConfiguration = VGSConfiguration(collector: collector, fieldName: "name")
        nameConfiguration.type = .none
        nameConfiguration.isRequiredValidOnly = true

        let cardHolderField = VGSTextField()
        cardHolderField.configuration = nameConfiguration
        cardHolderField.textField.text = "Joe Business"

        let expDateConfiguration = VGSConfiguration(collector: collector, fieldName: "expDate")
        expDateConfiguration.type = .expDate
        expDateConfiguration.isRequiredValidOnly = true

        let expDateField = VGSTextField()
        expDateField.configuration = expDateConfiguration
        expDateField.textField.text = "1123"

        let cvcConfiguration = VGSConfiguration(collector: collector, fieldName: "cvc")
        cvcConfiguration.type = .cvc
        cvcConfiguration.isRequiredValidOnly = true

        let cvcField = VGSTextField()
        cvcField.configuration = cvcConfiguration
        cvcField.textField.text = "123"
        
        let expectation = XCTestExpectation(description: "Sending data...")
               
        collector.submit(path: "post") { (data, error) in
           XCTAssertNotNil(data)
           XCTAssertNil(error)
           
           expectation.fulfill()
        }

        wait(for: [expectation], timeout: 30.0)
    }
    
     func testSubmitInvalidNotRequiredFieldsReturnsNotNil() {
        let cardConfiguration = VGSConfiguration(collector: collector, fieldName: "cardNumber")
        cardConfiguration.type = .cardNumber
        cardConfiguration.isRequiredValidOnly = false
        
        let cardTextField = VGSCardTextField()
        cardTextField.configuration = cardConfiguration
        cardTextField.textField.text = "4111 1111 1111 1112"
        
        let nameConfiguration = VGSConfiguration(collector: collector, fieldName: "name")
        nameConfiguration.type = .none
        nameConfiguration.isRequiredValidOnly = false

        let cardHolderField = VGSTextField()
        cardHolderField.configuration = nameConfiguration
        cardHolderField.textField.text = nil

        let expDateConfiguration = VGSConfiguration(collector: collector, fieldName: "expDate")
        expDateConfiguration.type = .expDate
        expDateConfiguration.isRequiredValidOnly = false

        let expDateField = VGSTextField()
        expDateField.configuration = expDateConfiguration
        expDateField.textField.text = "1123456789"

        let cvcConfiguration = VGSConfiguration(collector: collector, fieldName: "cvc")
        cvcConfiguration.type = .cvc
        cvcConfiguration.isRequiredValidOnly = false

        let cvcField = VGSTextField()
        cvcField.configuration = cvcConfiguration
        cvcField.textField.text = "123456789"
        
        let expectation = XCTestExpectation(description: "Sending data...")
               
        collector.submit(path: "post") { (data, error) in
           XCTAssertNotNil(data)
           XCTAssertNil(error)
           
           expectation.fulfill()
        }

        wait(for: [expectation], timeout: 30.0)
    }
    
    func testSubmitInvalidRequiredFieldsReturnsNil() {
        let cardConfiguration = VGSConfiguration(collector: collector, fieldName: "card_number")
        cardConfiguration.type = .cardNumber
        cardConfiguration.isRequiredValidOnly = true
        
        let cardTextField = VGSCardTextField()
        cardTextField.configuration = cardConfiguration
        cardTextField.textField.text = "4111 1111 1111 1112"
        
        let expectation = XCTestExpectation(description: "Sending data...")
               
        collector.submit(path: "post") { (data, error) in
           XCTAssertNil(data)
           XCTAssertNotNil(error)
           
           expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }
    
     func testSubmitEmptyRequiredFieldsReturnsNil() {
        let cardConfiguration = VGSConfiguration(collector: collector, fieldName: "cardNumber")
        cardConfiguration.type = .cardNumber
        cardConfiguration.isRequired = true
        
        let cardTextField = VGSCardTextField()
        cardTextField.configuration = cardConfiguration
        cardTextField.textField.text = ""
        
        let nameConfiguration = VGSConfiguration(collector: collector, fieldName: "name")
        nameConfiguration.type = .none
        nameConfiguration.isRequired = true

        let cardHolderField = VGSTextField()
        cardHolderField.configuration = nameConfiguration
        cardHolderField.textField.text = nil

        let expDateConfiguration = VGSConfiguration(collector: collector, fieldName: "expDate")
        expDateConfiguration.type = .expDate
        expDateConfiguration.isRequired = true

        let expDateField = VGSTextField()
        expDateField.configuration = expDateConfiguration
        expDateField.textField.text = ""

        let cvcConfiguration = VGSConfiguration(collector: collector, fieldName: "cvc")
        cvcConfiguration.type = .cvc
        cvcConfiguration.isRequired = true

        let cvcField = VGSTextField()
        cvcField.configuration = cvcConfiguration
        cvcField.textField.text = ""
        
        let expectation = XCTestExpectation(description: "Sending data...")
               
        collector.submit(path: "post") { (data, error) in
           XCTAssertNil(data)
           XCTAssertNotNil(error)
           
           expectation.fulfill()
        }

        wait(for: [expectation], timeout: 30.0)
    }
    
    func testSubmitEmptyNotRequiredFieldsReturnsNotNil() {
        let cardConfiguration = VGSConfiguration(collector: collector, fieldName: "cardNumber")
        cardConfiguration.type = .cardNumber
        cardConfiguration.isRequired = false
        
        let cardTextField = VGSCardTextField()
        cardTextField.configuration = cardConfiguration
        cardTextField.textField.text = ""
        
        let nameConfiguration = VGSConfiguration(collector: collector, fieldName: "name")
        nameConfiguration.type = .none
        nameConfiguration.isRequired = false

        let cardHolderField = VGSTextField()
        cardHolderField.configuration = nameConfiguration
        cardHolderField.textField.text = nil

        let expDateConfiguration = VGSConfiguration(collector: collector, fieldName: "expDate")
        expDateConfiguration.type = .expDate
        expDateConfiguration.isRequired = false

        let expDateField = VGSTextField()
        expDateField.configuration = expDateConfiguration
        expDateField.textField.text = ""

        let cvcConfiguration = VGSConfiguration(collector: collector, fieldName: "cvc")
        cvcConfiguration.type = .cvc
        cvcConfiguration.isRequired = false

        let cvcField = VGSTextField()
        cvcField.configuration = cvcConfiguration
        cvcField.textField.text = ""
        
        let expectation = XCTestExpectation(description: "Sending data...")
               
        collector.submit(path: "post") { (data, error) in
           XCTAssertNotNil(data)
           XCTAssertNil(error)
           
           expectation.fulfill()
        }

        wait(for: [expectation], timeout: 30.0)
    }
}
