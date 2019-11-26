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
    var collector: VGSCollect!
    var expDateTextField: VGSTextField!
    
    override func setUp() {
        collector = VGSCollect(id: "tntva5wfdrp")
        
        expDateTextField = VGSTextField()
        
        let config = VGSConfiguration(collector: collector, fieldName: "expDate")
        config.type = .expDate
        config.formatPattern = "##/####"
        
        expDateTextField.configuration = config
        
        expDateTextField.textField.text = "1223"
    }
    
    override func tearDown() {
        expDateTextField.configuration = nil
        collector  = nil
        expDateTextField = nil
    }
    
    func testAlias() {
        XCTAssertTrue(expDateTextField.state.fieldName == "expDate")
    }
    
    func testWrongDate() {
        expDateTextField.textField.text = "21/23"
        
        let state = expDateTextField.state
        
        XCTAssertFalse(state.isValid)
        XCTAssertFalse(state.isEmpty)
    }
}
