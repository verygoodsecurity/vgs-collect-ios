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
    var collector: VGSCollect!
    var cvvTextField: VGSTextField!
    
    override func setUp() {
        collector = VGSCollect(tnt: "tntva5wfdrp")
        
        cvvTextField = VGSTextField()
        
        let config = VGSConfiguration(collector: collector, fieldName: "cvv")
        config.type = .cvv
        config.isRequired = true
        cvvTextField.configuration = config
        
        cvvTextField.textField.text = "123"
    }
    
    override func tearDown() {
        collector  = nil
        cvvTextField = nil
    }
    
    func testAlias() {
        XCTAssertTrue(cvvTextField.state.fieldName == "cvv")
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
