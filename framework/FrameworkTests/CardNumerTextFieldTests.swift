//
//  ValidationTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/17/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
import VGSFramework

class CardNumerTextFieldTests: XCTestCase {
    var form: VGSForm!
    var cardNumerTextField: VGSTextField!
    
    override func setUp() {
        form = VGSForm(tnt: "tntva5wfdrp")
        
        cardNumerTextField = VGSTextField()
        
        let config = VGSConfiguration(form: form, alias: "cardNumber")
        config.type = .cardNumber
        cardNumerTextField.configuration = config
    }
    
    override func tearDown() {
        form  = nil
    }
    
    func testCardNumberAlias() {
        XCTAssertFalse(cardNumerTextField.state.alias == nil)
        XCTAssertFalse(cardNumerTextField.state.alias == "")
    }
    
    func testCardNumberStates() {
        let state = cardNumerTextField.state
        
        if let st = state as? CardState {
            XCTAssertTrue(st.isEmpty)
            XCTAssertFalse(st.isValid)
            XCTAssertTrue(st.first6 == "")
            XCTAssertTrue(st.last4 == "")
            XCTAssertTrue(st.cardBrand == .unknown)
        } else {
            XCTAssert(false)
        }
    }
}
