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
    
    override func setUp() {
        collector = VGSCollect(tnt: "tntva5wfdrp")
        
        cardNumerTextField = VGSTextField()
        
        let config = VGSConfiguration(form: collector, fieldName: "cardNumber")
        config.type = .cardNumber
        config.isRequired = true
        cardNumerTextField.configuration = config
        
        cardNumerTextField.textField.text = "5375 4114 0003 2996"
    }
    
    override func tearDown() {
        collector  = nil
        cardNumerTextField = nil
    }
    
    func testAlias() {
        XCTAssertNotNil(cardNumerTextField.fieldName == "cardNumer")
    }
    
    func testCardNumberText() {
        XCTAssertNotNil(cardNumerTextField.text == "5375 4114 0003 2996")
    }
    
    func testStates() {
        let state = cardNumerTextField.state
        
        if let st = state as? CardState {
            XCTAssertFalse(st.isEmpty)
            XCTAssertTrue(st.isValid)
            XCTAssertTrue(st.first6 == "537541")
            XCTAssertTrue(st.last4 == "2996")
            XCTAssertTrue(st.cardBrand == .mastercard)
        } else {
            XCTAssert(false, "State not for card field")
        }
    }
}
