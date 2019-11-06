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
        
        cardNumerTextField.textField.text = cardNum
    }
    
    override func tearDown() {
        collector  = nil
        cardNumerTextField = nil
    }
    
    func testAlias() {
        XCTAssertNotNil(cardNumerTextField.fieldName == "cardNumer")
    }
    
    func testCardNumberText() {
        XCTAssertNotNil(cardNumerTextField.textField.text == cardNum)
    }
    
    func testStates() {
        let state = cardNumerTextField.state
        
        if let st = state as? CardState {
            XCTAssertFalse(st.isEmpty)
            XCTAssertTrue(st.isValid)
            XCTAssertTrue(st.first6 == "411111")
            XCTAssertTrue(st.last4 == "1111")
            XCTAssertTrue(st.cardBrand == .visa)
        } else {
            XCTAssert(false, "State not for card field")
        }
    }
}
