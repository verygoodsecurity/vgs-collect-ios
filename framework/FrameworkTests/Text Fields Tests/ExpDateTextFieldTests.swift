//
//  ExpDateTextFieldTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/19/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework

class ExpDateTextFieldTests: XCTestCase {
    var form: VGSForm!
    var expDateTextField: VGSTextField!
    
    override func setUp() {
        form = VGSForm(tnt: "tntva5wfdrp")
        
        expDateTextField = VGSTextField()
        
        let config = VGSConfiguration(form: form, alias: "expDate")
        config.type = .dateExpiration
        expDateTextField.configuration = config
        
        expDateTextField.textField.text = "1223"
    }
    
    override func tearDown() {
        form  = nil
        expDateTextField = nil
    }
    
    func testAlias() {
        XCTAssertTrue(expDateTextField.state.alias == "expDate")
    }
    
    func testWrongDate() {
        let originalExpDate = expDateTextField.text
        expDateTextField.textField.text = "21/23"
        
        let state = expDateTextField.state
        
        XCTAssertFalse(state.isValid)
        XCTAssertFalse(state.isEmpty)
        
        expDateTextField.textField.text = originalExpDate
    }
    
    func testStates() {
        
    }
}
