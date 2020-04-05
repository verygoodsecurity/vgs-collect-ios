//
//  VGSCollectTest+Validation.swift
//  FrameworkTests
//
//  Created by Dima on 11.03.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSFramework

class VGSCollectValidationTests: XCTestCase {
    
    var collector: VGSCollect!
    
    override func setUp() {
        collector = VGSCollect(id: "tntva5wfdrp")
    }
    
    override func tearDown() {
        collector = nil
    }
    
    func testTenantIdValideReturnsFalse() {
        XCTAssertFalse(VGSCollect.tenantIDValid(""))
        XCTAssertFalse(VGSCollect.tenantIDValid(" "))
        XCTAssertFalse(VGSCollect.tenantIDValid("tnt_123456789"))
        XCTAssertFalse(VGSCollect.tenantIDValid("tnt 123456789"))
        XCTAssertFalse(VGSCollect.tenantIDValid("tnt@123456789"))
        XCTAssertFalse(VGSCollect.tenantIDValid("tenant/tenant"))
        XCTAssertFalse(VGSCollect.tenantIDValid("tenant:tenant"))
    }
    
    func testTenantIdValideReturnsTrue() {
        XCTAssertTrue(VGSCollect.tenantIDValid("1234567890"))
        XCTAssertTrue(VGSCollect.tenantIDValid("abcdefghijklmnopqarstuvwxyz"))
        XCTAssertTrue(VGSCollect.tenantIDValid("tnt1234567890"))
        XCTAssertTrue(VGSCollect.tenantIDValid("1234567890tnt"))
    }
    
    func testSubmitValidRequiredFieldsReturnsNotNil() {
        let cardConfiguration = VGSConfiguration(collector: collector, fieldName: "cardNumber")
        cardConfiguration.type = .cardNumber
        cardConfiguration.isRequiredValidOnly = true
        
        let cardTextField = VGSCardTextField()
        cardTextField.configuration = cardConfiguration
        cardTextField.textField.secureText = "4111 1111 1111 1111"
        
        let nameConfiguration = VGSConfiguration(collector: collector, fieldName: "name")
        nameConfiguration.type = .none
        nameConfiguration.isRequiredValidOnly = true

        let cardHolderField = VGSTextField()
        cardHolderField.configuration = nameConfiguration
        cardHolderField.textField.secureText = "Joe Business"

        let expDateConfiguration = VGSConfiguration(collector: collector, fieldName: "expDate")
        expDateConfiguration.type = .expDate
        expDateConfiguration.isRequiredValidOnly = true

        let expDateField = VGSTextField()
        expDateField.configuration = expDateConfiguration
        expDateField.textField.secureText = "1123"

        let cvcConfiguration = VGSConfiguration(collector: collector, fieldName: "cvc")
        cvcConfiguration.type = .cvc
        cvcConfiguration.isRequiredValidOnly = true

        let cvcField = VGSTextField()
        cvcField.configuration = cvcConfiguration
        cvcField.textField.secureText = "123"
        
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
