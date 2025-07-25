//
//  ValidationTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/17/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK
@MainActor
class CardNumerTextFieldTests: VGSCollectBaseTestCase {
    var collector: VGSCollect!
    var cardNumerTextField: VGSTextField!
    
    override func setUp() {
			  super.setUp()
        collector = VGSCollect(id: "tntva5wfdrp")
        
        cardNumerTextField = VGSTextField()
        
        let config = VGSConfiguration(collector: collector, fieldName: "cardNumber")
        config.type = .cardNumber
        config.isRequired = true
        config.isRequiredValidOnly = true
        cardNumerTextField.configuration = config
    }
    
    override func tearDown() {
        collector  = nil
        cardNumerTextField = nil
    }
    
    func testAlias() {
        XCTAssertTrue(cardNumerTextField.fieldName == "cardNumber")
    }
    
    func testCardNumberText() {
      XCTAssertTrue(cardNumerTextField.textField.secureText == "")
    }

  func testInitialTextfieldState() {
    
      let state = cardNumerTextField.state
      
      if let st = state as? VGSCardState {
          XCTAssertTrue(st.isEmpty)
          XCTAssertFalse(st.isDirty)
          XCTAssertFalse(st.isValid)
          XCTAssertTrue(st.isRequired)
          XCTAssertTrue(st.isRequiredValidOnly)
          XCTAssertTrue(st.inputLength == 0)
          XCTAssertTrue(st.bin == "")
          XCTAssertTrue(st.last4 == "")
          XCTAssertTrue(st.cardBrand == .unknown)
      } else {
          XCTAssert(false, "VGSCardState not valid")
      }
  }
  
    func testEmptyTextfieldState() {
        
        cardNumerTextField.setText("")
      
        let state = cardNumerTextField.state
        
        if let st = state as? VGSCardState {
            XCTAssertTrue(st.isEmpty)
            XCTAssertTrue(st.isDirty)
            XCTAssertFalse(st.isValid)
            XCTAssertTrue(st.isRequired)
            XCTAssertTrue(st.isRequiredValidOnly)
            XCTAssertTrue(st.inputLength == 0)
            XCTAssertTrue(st.bin == "")
            XCTAssertTrue(st.last4 == "")
            XCTAssertTrue(st.cardBrand == .unknown)
        } else {
            XCTAssert(false, "VGSCardState not valid")
        }
    }
  
    func testValidCardNumberState() {
      
      cardNumerTextField.setText("4111 1111 1111 1111")
           
      var state = cardNumerTextField.state

      if let st = state as? VGSCardState {
         XCTAssertFalse(st.isEmpty)
         XCTAssertTrue(st.isDirty)
         XCTAssertTrue(st.isValid)
         XCTAssertTrue(st.isDirty)
         XCTAssertTrue(st.isRequired)
         XCTAssertTrue(st.isRequiredValidOnly)
         XCTAssertTrue(st.inputLength == 16)
         // bin 8 digits
         XCTAssertTrue(st.bin == "41111111")
         XCTAssertTrue(st.last4 == "1111")
         XCTAssertTrue(st.cardBrand == .visa)
      } else {
         XCTAssert(false, "VGSCardState not valid")
      }
      
      cardNumerTextField.setText("3400 0009 9900 036")
      
      state = cardNumerTextField.state
      
      if let st = state as? VGSCardState {
          XCTAssertFalse(st.isEmpty)
          XCTAssertTrue(st.isDirty)
          XCTAssertTrue(st.isValid)
          XCTAssertTrue(st.isRequired)
          XCTAssertTrue(st.isRequiredValidOnly)
          XCTAssertTrue(st.inputLength == 15)
          XCTAssertTrue(st.bin == "340000")
          XCTAssertTrue(st.last4 == "0036")
          XCTAssertTrue(st.cardBrand == .amex)
      } else {
          XCTAssert(false, "VGSCardState not valid")
      }
      
      // Test with mask.
      cardNumerTextField.setText("5555 3412 4444 1115")
      state = cardNumerTextField.state

      if let st = state as? VGSCardState {
         XCTAssertFalse(st.isEmpty)
         XCTAssertTrue(st.isDirty)
         XCTAssertTrue(st.isValid)
         XCTAssertTrue(st.isRequired)
         XCTAssertTrue(st.isRequiredValidOnly)
         XCTAssertTrue(st.inputLength == 16)
          // bin 8 digits
         XCTAssertTrue(st.bin == "55553412")
         XCTAssertTrue(st.last4 == "1115")
         XCTAssertTrue(st.cardBrand == .mastercard)
      } else {
         XCTAssert(false, "VGSCardState not valid")
      }
    }
  
    func testNotValidCardNumberState() {
      cardNumerTextField.setText("4111 1111 1111 1234")
      
      var state = cardNumerTextField.state
      
      if let st = state as? VGSCardState {
          XCTAssertFalse(st.isEmpty)
          XCTAssertTrue(st.isDirty)
          XCTAssertFalse(st.isValid)
          XCTAssertTrue(st.isRequired)
          XCTAssertTrue(st.isRequiredValidOnly)
          XCTAssertTrue(st.inputLength == 16)
          XCTAssertTrue(st.bin == "")
          XCTAssertTrue(st.last4 == "")
          XCTAssertTrue(st.cardBrand == .visa)
      } else {
          XCTAssert(false, "State not for card field")
      }
      
      cardNumerTextField.setText("4111 1111 1")
      
      state = cardNumerTextField.state
      
      if let st = state as? VGSCardState {
          XCTAssertFalse(st.isEmpty)
          XCTAssertTrue(st.isDirty)
          XCTAssertFalse(st.isValid)
          XCTAssertTrue(st.isRequired)
          XCTAssertTrue(st.isRequiredValidOnly)
          XCTAssertTrue(st.inputLength == 9)
          XCTAssertTrue(st.bin == "")
          XCTAssertTrue(st.last4 == "")
          XCTAssertTrue(st.cardBrand == .visa)
      } else {
          XCTAssert(false, "VGSCardState not valid")
      }
      
      let newValue = cardNumerTextField.textField.secureText! + "111"
      cardNumerTextField.setText(newValue)
      
      state = cardNumerTextField.state
      
      if let st = state as? VGSCardState {
          XCTAssertFalse(st.isEmpty)
          XCTAssertTrue(st.isDirty)
          XCTAssertFalse(st.isValid)
          XCTAssertTrue(st.isRequired)
          XCTAssertTrue(st.isRequiredValidOnly)
          XCTAssertTrue(st.inputLength == 12)
          XCTAssertTrue(st.bin == "")
          XCTAssertTrue(st.last4 == "")
          XCTAssertTrue(st.cardBrand == .visa)
      } else {
          XCTAssert(false, "VGSCardState not valid")
      }
      
      cardNumerTextField.setText("")
      
      state = cardNumerTextField.state
      
      if let st = state as? VGSCardState {
          XCTAssertTrue(st.isEmpty)
          XCTAssertTrue(st.isDirty)
          XCTAssertFalse(st.isValid)
          XCTAssertTrue(st.isRequired)
          XCTAssertTrue(st.isRequiredValidOnly)
          XCTAssertTrue(st.inputLength == 0)
          XCTAssertTrue(st.bin == "")
          XCTAssertTrue(st.last4 == "")
          XCTAssertTrue(st.cardBrand == .unknown)
      } else {
          XCTAssert(false, "VGSCardState not valid")
      }
    }
  
    func testCardNumberStateWithoutEditingOnFirstResponderChange() {
      
      cardNumerTextField.becomeFirstResponder()
      var state = cardNumerTextField.state
      
      if let st = state as? VGSCardState {
          XCTAssertTrue(st.isEmpty)
          XCTAssertFalse(st.isDirty)
          XCTAssertFalse(st.isValid)
          XCTAssertTrue(st.isRequired)
          XCTAssertTrue(st.isRequiredValidOnly)
          XCTAssertTrue(st.inputLength == 0)
          XCTAssertTrue(st.bin == "")
          XCTAssertTrue(st.last4 == "")
          XCTAssertTrue(st.cardBrand == .unknown)
      } else {
          XCTAssert(false, "VGSCardState not valid")
      }
      
      cardNumerTextField.resignFirstResponder()
      state = cardNumerTextField.state
      
      if let st = state as? VGSCardState {
          XCTAssertTrue(st.isEmpty)
          XCTAssertFalse(st.isDirty)
          XCTAssertFalse(st.isValid)
          XCTAssertTrue(st.isRequired)
          XCTAssertTrue(st.isRequiredValidOnly)
          XCTAssertTrue(st.inputLength == 0)
          XCTAssertTrue(st.bin == "")
          XCTAssertTrue(st.last4 == "")
          XCTAssertTrue(st.cardBrand == .unknown)
      } else {
          XCTAssert(false, "VGSCardState not valid")
      }
      
      func testCardNumberStateWithEditingOnFirstResponderChange() {
        
        cardNumerTextField.becomeFirstResponder()
        cardNumerTextField.setText("4111 1111 1")

        var state = cardNumerTextField.state

        if let st = state as? VGSCardState {
           XCTAssertFalse(st.isEmpty)
           XCTAssertTrue(st.isDirty)
           XCTAssertFalse(st.isValid)
           XCTAssertTrue(st.isRequired)
           XCTAssertTrue(st.isRequiredValidOnly)
           XCTAssertTrue(st.inputLength == 9)
           XCTAssertTrue(st.bin == "")
           XCTAssertTrue(st.last4 == "")
           XCTAssertTrue(st.cardBrand == .visa)
        } else {
           XCTAssert(false, "VGSCardState not valid")
        }
        
        cardNumerTextField.resignFirstResponder()
        
        state = cardNumerTextField.state

        if let st = state as? VGSCardState {
           XCTAssertFalse(st.isEmpty)
           XCTAssertTrue(st.isDirty)
           XCTAssertFalse(st.isValid)
           XCTAssertTrue(st.isRequired)
           XCTAssertTrue(st.isRequiredValidOnly)
           XCTAssertTrue(st.inputLength == 9)
           XCTAssertTrue(st.bin == "")
           XCTAssertTrue(st.last4 == "")
           XCTAssertTrue(st.cardBrand == .visa)
        } else {
           XCTAssert(false, "VGSCardState not valid")
        }
        
        cardNumerTextField.becomeFirstResponder()

        state = cardNumerTextField.state

        if let st = state as? VGSCardState {
           XCTAssertFalse(st.isEmpty)
           XCTAssertTrue(st.isDirty)
           XCTAssertFalse(st.isValid)
           XCTAssertTrue(st.isRequired)
           XCTAssertTrue(st.isRequiredValidOnly)
           XCTAssertTrue(st.inputLength == 9)
           XCTAssertTrue(st.bin == "")
           XCTAssertTrue(st.last4 == "")
           XCTAssertTrue(st.cardBrand == .visa)
        } else {
           XCTAssert(false, "VGSCardState not valid")
        }
      }
  }
    
    /// Test accessibility properties
    func testAccessibilityAttributes() {
        // Hint
        let accHint = "accessibility hint"
        cardNumerTextField.textFieldAccessibilityHint = accHint
        XCTAssertNotNil(cardNumerTextField.textFieldAccessibilityHint)
        XCTAssertEqual(cardNumerTextField.textFieldAccessibilityHint, accHint)
        
        // Label
        let accLabel = "accessibility label"
        cardNumerTextField.textFieldAccessibilityLabel = accLabel
        XCTAssertNotNil(cardNumerTextField.textFieldAccessibilityLabel)
        XCTAssertEqual(cardNumerTextField.textFieldAccessibilityLabel, accLabel)
        
        // Element
        cardNumerTextField.textFieldIsAccessibilityElement = true
        XCTAssertTrue(cardNumerTextField.textFieldIsAccessibilityElement)
        
        // Value
        let accValue = "accessibility value"
        cardNumerTextField.textField.secureText = accValue
        XCTAssertTrue(cardNumerTextField.textField.secureText!.isEmpty)
        XCTAssertNil(cardNumerTextField.textField.accessibilityValue)
    }
}
