//
//  CVVTextFieldTests.swift
//  FrameworkTests
//

import XCTest
@testable import VGSCollectSDK
@MainActor 
class CVVTextFieldTests: VGSCollectBaseTestCase {
    var collector: VGSCollect!
    var cvvTextField: VGSTextField!
    
    override func setUp() {
			  super.setUp()
        collector = VGSCollect(id: "tntva5wfdrp")
        
        cvvTextField = VGSTextField()
        
        let config = VGSConfiguration(collector: collector, fieldName: "cvc")
        config.type = .cvc
        config.isRequired = true
        cvvTextField.configuration = config
        
        cvvTextField.textField.secureText = "123"
        cvvTextField.focusOn()
    }
    
    override func tearDown() {
        collector  = nil
        cvvTextField = nil
    }
    
    func testAlias() {
        XCTAssertTrue(cvvTextField.state.fieldName == "cvc")
    }
    
    func testContent() {
        XCTAssertTrue(cvvTextField.textField.secureText == "123")
    }
    
    func testStates() {
        cvvTextField.textField.secureText = "123"
        let state = cvvTextField.state
        XCTAssertFalse(state.isEmpty)
        XCTAssertTrue(state.isValid)
        XCTAssertTrue(state.isRequired)
        XCTAssertNotNil(state.description)
      
        if state is VGSCardState {
            XCTFail("VGSCardState shouldn't be available for .cvc configuration")
        }
    }
    
    func testStateDescription() {
        let expectation = XCTestExpectation(description: "Update TF status.")
        
        collector.observeStates = { objects in
                        
            XCTAssert(objects.count == 1)
            
            if let state = objects.first?.state {
                XCTAssertFalse(state.isEmpty)
                XCTAssertTrue(state.isValid)
                XCTAssertTrue(state.isRequired)
                XCTAssertTrue(state.isDirty)
            } else {
                XCTFail("Text field state didn't received.")
            }
            
            expectation.fulfill()
        }
        
        cvvTextField.setText("123")
        cvvTextField.setText("123456")
        cvvTextField.setText("aaa1234qwwe")
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCVCFormat() {
        let cardNumberAmex = "378282246310005"  // cvc format 4 digits (####)
        let cardNumberVisa = "4111111111111111" // cvc general format 3 digits (###)
        let cardNumberDiner = "30569309025904"  // cvc general format 3 digits (###)
        
        let cardNumberTextField = VGSCardTextField()
        let cardConfig = VGSConfiguration(collector: collector, fieldName: "testCardNum")
        cardConfig.type = .cardNumber
        cardNumberTextField.configuration = cardConfig
        
        // set Amex card number
        cardNumberTextField.textField.secureText = cardNumberAmex
        cardNumberTextField.focusOn()
        XCTAssert(cvvTextField.textField.formatPattern == "####")
        
        cardNumberTextField.textField.secureText = cardNumberVisa
        cardNumberTextField.focusOn()
        XCTAssert(cvvTextField.textField.formatPattern == "###")
        
        cardNumberTextField.textField.secureText = cardNumberDiner
        cardNumberTextField.focusOn()
        XCTAssert(cvvTextField.textField.formatPattern == "###")
        
        cardNumberTextField.textField.secureText = ""
        cardNumberTextField.focusOn()
        XCTAssert(cvvTextField.textField.formatPattern == "####", "Default format is wrong. Should be ####")
    }
    
    /// Test accessibility properties
    func testAccessibilityAttributes() {
        // Hint
        let accHint = "accessibility hint"
        cvvTextField.textFieldAccessibilityHint = accHint
        XCTAssertNotNil(cvvTextField.textFieldAccessibilityHint)
        XCTAssertEqual(cvvTextField.textFieldAccessibilityHint, accHint)
        
        // Label
        let accLabel = "accessibility label"
        cvvTextField.textFieldAccessibilityLabel = accLabel
        XCTAssertNotNil(cvvTextField.textFieldAccessibilityLabel)
        XCTAssertEqual(cvvTextField.textFieldAccessibilityLabel, accLabel)
        
        // Element
        cvvTextField.textFieldIsAccessibilityElement = true
        XCTAssertTrue(cvvTextField.textFieldIsAccessibilityElement)
        
        // Value
        let accValue = "accessibility value"
        cvvTextField.textField.secureText = accValue
        XCTAssertTrue(cvvTextField.textField.secureText!.isEmpty)
        XCTAssertNil(cvvTextField.textField.accessibilityValue)
    }
}
