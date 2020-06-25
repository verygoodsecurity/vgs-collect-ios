//
//  ValidationRulesTest.swift
//  VGSCollectSDK
//
//  Created by Dima on 24.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class ValidationRulesTest: XCTestCase {

    var form: VGSCollect!
    var textfield: VGSTextField!
    
    override func setUp() {
      form = VGSCollect(id: "tntva5wfdrp")
      textfield = VGSTextField()
    }

    override func tearDown() {
        form = nil
        textfield = nil
    }
    
    func testCardNumberRule() {
      var config = VGSConfiguration.init(collector: form, fieldName: "test_field")
      config.type = .none
      config.validationRules = VGSValidationRuleSet(rules: [
        VGSValidationRuleCreditCard(error: "card error")
      ])
    }
  
    func testPatternRule() {

    }
  
    func testLengthRule() {

    }
    
  
    func testNoRule() {
      
    }
    
    func textMultipleRules() {
      
    }
}

