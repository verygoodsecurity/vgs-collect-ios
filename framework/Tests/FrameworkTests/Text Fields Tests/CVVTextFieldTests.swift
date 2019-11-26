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
        collector = VGSCollect(id: "tntva5wfdrp")
        
        cvvTextField = VGSTextField()
        
        let config = VGSConfiguration(collector: collector, fieldName: "cvc")
        config.type = .cvc
        config.isRequired = true
        cvvTextField.configuration = config
        
        cvvTextField.textField.text = "123"
    }
    
    override func tearDown() {
        collector  = nil
        cvvTextField = nil
    }
    
    func testAlias() {
        XCTAssertTrue(cvvTextField.state.fieldName == "cvc")
    }
    
    func testContent() {
        XCTAssertTrue(cvvTextField.text == "123")
    }
    
    func testStates() {
        let state = cvvTextField.state
        XCTAssertFalse(state.isEmpty)
        XCTAssertTrue(state.isValid)
        XCTAssertTrue(state.isRequired)
        XCTAssertNotNil(state.description)
    }
    
    func testStateDescription() {
        let expectation = XCTestExpectation(description: "Update TF status.")
        
        collector.observeStates = { objects in
            
            expectation.fulfill()
            
            XCTAssert(objects.count == 1)
            
            if let state = objects.first?.state {
                XCTAssertFalse(state.isEmpty)
                XCTAssertTrue(state.isValid)
                XCTAssertTrue(state.isRequired)
            } else {
                XCTFail("Text field state didn't received.")
            }
        }
        
        cvvTextField.textFieldDidChange(UITextField())
        
        wait(for: [expectation], timeout: 1.0)
    }
}
