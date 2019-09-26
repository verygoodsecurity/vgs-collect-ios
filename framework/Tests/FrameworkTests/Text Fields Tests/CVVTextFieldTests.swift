//
//  CVVTextFieldTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 9/19/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework

class CVVTextFieldTests: XCTestCase {
    var form: VGSForm!
    var cvvTextField: VGSTextField!
    
    override func setUp() {
        form = VGSForm(tnt: "tntva5wfdrp")
        
        cvvTextField = VGSTextField()
        
        let config = VGSConfiguration(form: form, alias: "cvv")
        config.type = .cvv
        config.isRequired = true
        cvvTextField.configuration = config
        
        cvvTextField.textField.text = "123"
    }
    
    override func tearDown() {
        form  = nil
        cvvTextField = nil
    }
    
    func testAlias() {
        XCTAssertTrue(cvvTextField.state.alias == "cvv")
    }
    
    func testContent() {
        XCTAssertTrue(cvvTextField.text == "123")
    }
    
    func testStates() {
        let state = cvvTextField.state
        XCTAssertFalse(state.isEmpty)
        XCTAssertTrue(state.isValid)
        XCTAssertTrue(state.isRequired)
    }
}
