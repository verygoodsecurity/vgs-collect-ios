//
//  ValidationRulesTest.swift
//  VGSCollectSDK
//
//  Created by Dima on 24.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class ValidationRulesTest: VGSCollectBaseTestCase {

    var form: VGSCollect!
    var textfield: VGSTextField!
    
    override func setUp() {
			super.setUp()
      form = VGSCollect(id: "tntva5wfdrp")
      textfield = VGSTextField()
    }

    override func tearDown() {
        form = nil
        textfield = nil
    }
    
    func testCardNumberRule() {
      let error = "card_num_error"
      let config = VGSConfiguration(collector: form, fieldName: "test_field")
      config.type = .cardNumber
      config.validationRules = VGSValidationRuleSet(rules: [
        VGSValidationRulePaymentCard(error: error)
      ])
      textfield.configuration = config
      textfield.textField.secureText = "4111111111111111"
      XCTAssertTrue(textfield.state.isValid)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
      
      textfield.textField.secureText = "0222602986549272"
      XCTAssertTrue(textfield.state.isValid == false)
      XCTAssertTrue(textfield.state.validationErrors.count == 1)
      XCTAssertTrue(textfield.state.validationErrors.first == error)
      
      config.validationRules = VGSValidationRuleSet(rules: [
        VGSValidationRulePaymentCard(error: error, validateUnknownCardBrand: true)
      ])
      textfield.configuration = config
      textfield.textField.secureText = "4111111111111111"
      XCTAssertTrue(textfield.state.isValid)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
      
      textfield.textField.secureText = "0222602986549272"
      XCTAssertTrue(textfield.state.isValid)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
    }
  
    func testPatternRule() {
      let error = "pattern_error"
      let config = VGSConfiguration(collector: form, fieldName: "test_field")
      config.type = .none
      config.validationRules = VGSValidationRuleSet(rules: [
        VGSValidationRulePattern(pattern: "^111\\d*$", error: error)
      ])
      textfield.configuration = config
      textfield.textField.secureText = "111"
      XCTAssertTrue(textfield.state.isValid)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
      
      textfield.textField.secureText = "123"
      XCTAssertTrue(textfield.state.isValid == false)
      XCTAssertTrue(textfield.state.validationErrors.count == 1)
      XCTAssertTrue(textfield.state.validationErrors.first == error)
    }
  
    func testLengthRule() {
      let error = "length_error"
      let config = VGSConfiguration(collector: form, fieldName: "test_field")
      config.type = .none
      config.validationRules = VGSValidationRuleSet(rules: [
        VGSValidationRuleLength(min: 5, max: 9, error: error)
      ])
      textfield.configuration = config
      textfield.textField.secureText = "12345"
      XCTAssertTrue(textfield.state.isValid)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
      
      textfield.textField.secureText = "12345abcd"
      XCTAssertTrue(textfield.state.isValid)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
      
      textfield.textField.secureText = ""
      XCTAssertTrue(textfield.state.isValid == false)
      XCTAssertTrue(textfield.state.validationErrors.count == 1)
      XCTAssertTrue(textfield.state.validationErrors.first == error)
      
      textfield.textField.secureText = "12345abcd12345"
      XCTAssertTrue(textfield.state.isValid == false)
      XCTAssertTrue(textfield.state.validationErrors.count == 1)
      XCTAssertTrue(textfield.state.validationErrors.first == error)
    }
  
    func testNoRule() {
      let config = VGSConfiguration(collector: form, fieldName: "test_field")
      config.type = .none
      textfield.configuration = config
      XCTAssertTrue(textfield.state.isValid)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
      
      textfield.textField.secureText = "12345"
      XCTAssertTrue(textfield.state.isValid)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
      
    }
  
    func testExpirationDateRule() {
      let error = "error"
      let config = VGSConfiguration(collector: form, fieldName: "test_field")
      config.type = .expDate
      config.formatPattern = ""
      
      textfield.configuration = config
      textfield.textField.secureText = "1022"
      XCTAssertTrue(textfield.state.isValid)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
      
      textfield.textField.secureText = "102022"
      XCTAssertTrue(textfield.state.isValid == false)
      XCTAssertTrue(textfield.state.validationErrors.count == 1)
      
      config.validationRules = VGSValidationRuleSet(rules: [
        VGSValidationRuleCardExpirationDate(dateFormat: .shortYear, error: error)
      ])
      textfield.configuration = config
      textfield.textField.secureText = "1022"
      XCTAssertTrue(textfield.state.isValid)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
      
      textfield.textField.secureText = "102022"
      XCTAssertTrue(textfield.state.isValid == false)
      XCTAssertTrue(textfield.state.validationErrors.count == 1)
      XCTAssertTrue(textfield.state.validationErrors.first == error)
      
      /// Test  month in valid range
      textfield.textField.secureText = "1322"
      XCTAssertTrue(textfield.state.isValid == false)
      XCTAssertTrue(textfield.state.validationErrors.count == 1)
      XCTAssertTrue(textfield.state.validationErrors.first == error)
      
      textfield.textField.secureText = "0122"
      XCTAssertTrue(textfield.state.isValid == true)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
      
      textfield.textField.secureText = "1222"
      XCTAssertTrue(textfield.state.isValid == true)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
      
      textfield.textField.secureText = "0022"
      XCTAssertTrue(textfield.state.isValid == false)
      XCTAssertTrue(textfield.state.validationErrors.count == 1)
      XCTAssertTrue(textfield.state.validationErrors.first == error)

      config.validationRules = VGSValidationRuleSet(rules: [
        VGSValidationRuleCardExpirationDate(dateFormat: .longYear, error: error)
      ])
      textfield.configuration = config
      textfield.textField.secureText = "1022"
      XCTAssertTrue(textfield.state.isValid == false)
      XCTAssertTrue(textfield.state.validationErrors.count == 1)
      XCTAssertTrue(textfield.state.validationErrors.first == error)
      
      textfield.textField.secureText = "102022"
      XCTAssertTrue(textfield.state.isValid)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
    }
    
    func testMultipleRules() {
      let lengthError = "length_error"
      let patternError = "pattern_error"
      let config = VGSConfiguration(collector: form, fieldName: "test_field")
      config.type = .none
      config.validationRules = VGSValidationRuleSet(rules: [
        VGSValidationRuleLength(min: 5, max: 9, error: lengthError),
        VGSValidationRulePattern(pattern: "^111\\d*$", error: patternError)
      ])
      textfield.configuration = config
      XCTAssertTrue(textfield.state.isValid == false)
      XCTAssertTrue(textfield.state.validationErrors.count == 2)
      XCTAssertTrue(textfield.state.validationErrors.contains(lengthError))
      XCTAssertTrue(textfield.state.validationErrors.contains(patternError))
      
      textfield.textField.secureText = "1234"
      XCTAssertTrue(textfield.state.isValid == false)
      XCTAssertTrue(textfield.state.validationErrors.count == 2)
      XCTAssertTrue(textfield.state.validationErrors.contains(lengthError))
      XCTAssertTrue(textfield.state.validationErrors.contains(patternError))
      
      textfield.textField.secureText = "1234567890"
      XCTAssertTrue(textfield.state.isValid == false)
      XCTAssertTrue(textfield.state.validationErrors.count == 2)
      XCTAssertTrue(textfield.state.validationErrors.contains(lengthError))
      XCTAssertTrue(textfield.state.validationErrors.contains(patternError))
      
      textfield.textField.secureText = "12345"
      XCTAssertTrue(textfield.state.isValid == false)
      XCTAssertTrue(textfield.state.validationErrors.count == 1)
      XCTAssertTrue(textfield.state.validationErrors.contains(patternError))
      
      textfield.textField.secureText = "1112"
      XCTAssertTrue(textfield.state.isValid == false)
      XCTAssertTrue(textfield.state.validationErrors.count == 1)
      XCTAssertTrue(textfield.state.validationErrors.contains(lengthError))
      
      textfield.textField.secureText = "11123"
      XCTAssertTrue(textfield.state.isValid)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
      
      textfield.textField.secureText = "111234567"
      XCTAssertTrue(textfield.state.isValid)
      XCTAssertTrue(textfield.state.validationErrors.count == 0)
    }
}
