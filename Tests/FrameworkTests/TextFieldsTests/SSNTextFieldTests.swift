//
//  SSNTextFieldTests.swift
//  FrameworkTests
//
//  Created by Dima on 29.05.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK
@MainActor 
class SSNTextFieldTests: VGSCollectBaseTestCase {
    var collector: VGSCollect!
    var ssnTextField: VGSTextField!
    
    override func setUp() {
			  super.setUp()
        collector = VGSCollect(id: "tntva5wfdrp")
        
        ssnTextField = VGSTextField()
        
        let config = VGSConfiguration(collector: collector, fieldName: "ssn")
        config.type = .ssn
        config.isRequired = true
        ssnTextField.configuration = config

      ssnTextField.textField.secureText = "123-44-5555"
    }
    
    override func tearDown() {
        collector  = nil
        ssnTextField = nil
    }
    
    func testAlias() {
        XCTAssertTrue(ssnTextField.state.fieldName == "ssn")
    }
    
    func testContent() {
        XCTAssertTrue(ssnTextField.textField.secureText == "123-44-5555")
    }
    
    func testStates() {
        let state = ssnTextField.state
        XCTAssertFalse(state.isEmpty)
        XCTAssertTrue(state.isValid)
        XCTAssertTrue(state.isRequired)
        XCTAssertNotNil(state.description)
        XCTAssertTrue(state is VGSSSNState, "SSNState should be available for .ssn configuration")
    }
  
    func testNotValidSSNReturnsFalse() {
      let config = VGSConfiguration(collector: collector, fieldName: "ssn")
      config.type = .ssn
      config.formatPattern = ""
      ssnTextField.configuration = config
      
      let notValidSSN = [
        "000345567",
        "666467547",
        "456005634",
        "573650000",
        "000000000",
        "900567444"
      ]
      
      for ssn in notValidSSN {
        ssnTextField.textField.secureText = ssn
        ssnTextField.focusOn()
        XCTAssertFalse(ssnTextField.state.isValid)
        XCTAssertFalse(ssnTextField.state.isEmpty)
        if let state = ssnTextField.state as? VGSSSNState {
          XCTAssertTrue(state.last4 == "")
        }
      }
    }
  
    func testValidSSNReturnsTrue() {
      let config = VGSConfiguration(collector: collector, fieldName: "ssn")
      config.type = .ssn
      ssnTextField.configuration = config
      
      let validSSN = [
        "111111112",
        "222232222",
        "112111112",
        "221232222",
        "455555555",
        "166666666",
        "899999999",
        "001010001",
        "100123456",
        "143104563",
        "235231000",
        "823423423",
        "665123455",
        "123456780",
        "219099998",
        "078051125",
        "457555465",
        "234567890123456789"
      ]
      
      for ssn in validSSN {
        ssnTextField.textField.secureText = ssn
        ssnTextField.focusOn()
        XCTAssertTrue(ssnTextField.state.isValid)
        XCTAssertTrue(ssnTextField.state.inputLength == 9)
        XCTAssertFalse(ssnTextField.state.isEmpty)
        
        if let state = ssnTextField.state as? VGSSSNState {
          XCTAssertTrue(state.last4.count == 4)
        }
      }
    }
    
    /// Test accessibility properties
    func testAccessibilityAttributes() {
        // Hint
        let accHint = "accessibility hint"
        ssnTextField.textFieldAccessibilityHint = accHint
        XCTAssertNotNil(ssnTextField.textFieldAccessibilityHint)
        XCTAssertEqual(ssnTextField.textFieldAccessibilityHint, accHint)
        
        // Label
        let accLabel = "accessibility label"
        ssnTextField.textFieldAccessibilityLabel = accLabel
        XCTAssertNotNil(ssnTextField.textFieldAccessibilityLabel)
        XCTAssertEqual(ssnTextField.textFieldAccessibilityLabel, accLabel)
        
        // Element
        ssnTextField.textFieldIsAccessibilityElement = true
        XCTAssertTrue(ssnTextField.textFieldIsAccessibilityElement)
        
        // Value
        let accValue = "accessibility value"
        ssnTextField.textField.secureText = accValue
        XCTAssertTrue(ssnTextField.textField.secureText!.isEmpty)
        XCTAssertNil(ssnTextField.textField.accessibilityValue)
    }
}
