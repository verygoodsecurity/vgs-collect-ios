//
//  ValidationTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/17/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework

class CardNumerTextFieldTests: XCTestCase {
    var collector: VGSCollect!
    var cardNumerTextField: VGSTextField!
    var cardNum = "4111 1111 1111 1111"
    
    override func setUp() {
        collector = VGSCollect(id: "tntva5wfdrp")
        
        cardNumerTextField = VGSTextField()
        
        let config = VGSConfiguration(collector: collector, fieldName: "cardNumber")
        config.type = .cardNumber
        config.isRequired = true
        cardNumerTextField.configuration = config
    }
    
    override func tearDown() {
        collector  = nil
        cardNumerTextField = nil
    }
    
    func testAlias() {
        XCTAssertNotNil(cardNumerTextField.fieldName == "cardNumber")
    }
    
    func testCardNumberText() {
        XCTAssertNotNil(cardNumerTextField.textField.secureText == cardNum)
    }
    
    func testStates() {
        
        var state = cardNumerTextField.state
        
        if let st = state as? CardState {
            XCTAssertTrue(st.isEmpty)
            XCTAssertFalse(st.isValid)
            XCTAssertFalse(st.bin == "411111")
            XCTAssertFalse(st.last4 == "1111")
            XCTAssertFalse(st.cardBrand == .visa)
        } else {
            XCTAssert(false, "State not for card field")
        }
        
        cardNumerTextField.textField.secureText = cardNum
        
        state = cardNumerTextField.state
        
        if let st = state as? CardState {
            XCTAssertFalse(st.isEmpty)
            XCTAssertTrue(st.isValid)
            XCTAssertTrue(st.bin == "411111")
            XCTAssertTrue(st.last4 == "1111")
            XCTAssertTrue(st.cardBrand == .visa)
        } else {
            XCTAssert(false, "State not for card field")
        }
    }
}
