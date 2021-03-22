//
//  ValidationTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/17/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

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
      
      if let st = state as? CardState {
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
          XCTAssert(false, "CardState not valid")
      }
  }
  
    func testEmptyTextfieldState() {
        
        cardNumerTextField.setText("")
      
        let state = cardNumerTextField.state
        
        if let st = state as? CardState {
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
            XCTAssert(false, "CardState not valid")
        }
    }
  
    func testValidCardNumberState() {
      
      cardNumerTextField.setText("4111 1111 1111 1111")
           
      var state = cardNumerTextField.state

      if let st = state as? CardState {
         XCTAssertFalse(st.isEmpty)
         XCTAssertTrue(st.isDirty)
         XCTAssertTrue(st.isValid)
         XCTAssertTrue(st.isDirty)
         XCTAssertTrue(st.isRequired)
         XCTAssertTrue(st.isRequiredValidOnly)
         XCTAssertTrue(st.inputLength == 16)
         XCTAssertTrue(st.bin == "411111")
         XCTAssertTrue(st.last4 == "1111")
         XCTAssertTrue(st.cardBrand == .visa)
      } else {
         XCTAssert(false, "CardState not valid")
      }
      
      cardNumerTextField.setText("3400 0009 9900 036")
      
      state = cardNumerTextField.state
      
      if let st = state as? CardState {
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
          XCTAssert(false, "CardState not valid")
      }
      
      // Test with mask.
      cardNumerTextField.setText("4111 1111 1111 1111")
      state = cardNumerTextField.state

      if let st = state as? CardState {
         XCTAssertFalse(st.isEmpty)
         XCTAssertTrue(st.isDirty)
         XCTAssertTrue(st.isValid)
         XCTAssertTrue(st.isRequired)
         XCTAssertTrue(st.isRequiredValidOnly)
         XCTAssertTrue(st.inputLength == 16)
         XCTAssertTrue(st.bin == "411111")
         XCTAssertTrue(st.last4 == "1111")
         XCTAssertTrue(st.cardBrand == .visa)
      } else {
         XCTAssert(false, "CardState not valid")
      }
    }
  
    func testNotValidCardNumberState() {
      cardNumerTextField.setText("4111 1111 1111 1234")
      
      var state = cardNumerTextField.state
      
      if let st = state as? CardState {
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
      
      if let st = state as? CardState {
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
          XCTAssert(false, "CardState not valid")
      }
      
      let newValue = cardNumerTextField.textField.secureText! + "111"
      cardNumerTextField.setText(newValue)
      
      state = cardNumerTextField.state
      
      if let st = state as? CardState {
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
          XCTAssert(false, "CardState not valid")
      }
      
      cardNumerTextField.setText("")
      
      state = cardNumerTextField.state
      
      if let st = state as? CardState {
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
          XCTAssert(false, "CardState not valid")
      }
    }
  
    func testCardNumberStateWithoutEditingOnFirstResponderChange() {
      
      cardNumerTextField.becomeFirstResponder()
      var state = cardNumerTextField.state
      
      if let st = state as? CardState {
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
          XCTAssert(false, "CardState not valid")
      }
      
      cardNumerTextField.resignFirstResponder()
      state = cardNumerTextField.state
      
      if let st = state as? CardState {
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
          XCTAssert(false, "CardState not valid")
      }
      
      func testCardNumberStateWithEditingOnFirstResponderChange() {
        
        cardNumerTextField.becomeFirstResponder()
        cardNumerTextField.setText("4111 1111 1")

        var state = cardNumerTextField.state

        if let st = state as? CardState {
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
           XCTAssert(false, "CardState not valid")
        }
        
        cardNumerTextField.resignFirstResponder()
        
        state = cardNumerTextField.state

        if let st = state as? CardState {
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
           XCTAssert(false, "CardState not valid")
        }
        
        cardNumerTextField.becomeFirstResponder()

        state = cardNumerTextField.state

        if let st = state as? CardState {
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
           XCTAssert(false, "CardState not valid")
        }
      }
  }
}
