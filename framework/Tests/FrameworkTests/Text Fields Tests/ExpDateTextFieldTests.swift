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
        expDateTextField.configuration = config
        
        expDateTextField.textField.secureText = "1223"
    }
    
    override func tearDown() {
        expDateTextField.configuration = nil
        collector  = nil
        expDateTextField = nil
    }
    
    func testAlias() {
        XCTAssertTrue(expDateTextField.state.fieldName == "expDate")
    }
    
    func testNotValidDateReturnsFalse() {
        
        expDateTextField.textField.secureText = "21/23"
        expDateTextField.focusOn()
        XCTAssertFalse(expDateTextField.state.isValid)
        XCTAssertFalse(expDateTextField.state.isEmpty)
        
        expDateTextField.textField.secureText = "01/20"
        expDateTextField.focusOn()
        XCTAssertFalse(expDateTextField.state.isValid)
        XCTAssertFalse(expDateTextField.state.isEmpty)
        
        expDateTextField.textField.secureText = "01/01"
        expDateTextField.focusOn()
        XCTAssertFalse(expDateTextField.state.isValid)
        XCTAssertFalse(expDateTextField.state.isEmpty)
        
        expDateTextField.textField.secureText = "00/00"
        expDateTextField.focusOn()
        XCTAssertFalse(expDateTextField.state.isValid)
        XCTAssertFalse(expDateTextField.state.isEmpty)
        
        expDateTextField.textField.secureText = "20/12"
        expDateTextField.focusOn()
        XCTAssertFalse(expDateTextField.state.isValid)
        XCTAssertFalse(expDateTextField.state.isEmpty)
    }
    
    func testValidDateReturnsTrue() {
        
        expDateTextField.textField.secureText = "01/21"
        expDateTextField.focusOn()
        XCTAssertTrue(expDateTextField.state.isValid)
        XCTAssertFalse(expDateTextField.state.isEmpty)
        
        expDateTextField.textField.secureText = "10/21"
        expDateTextField.focusOn()
        XCTAssertTrue(expDateTextField.state.isValid)
        XCTAssertFalse(expDateTextField.state.isEmpty)
        
        expDateTextField.textField.secureText = "12/22"
        expDateTextField.focusOn()
        XCTAssertTrue(expDateTextField.state.isValid)
        XCTAssertFalse(expDateTextField.state.isEmpty)
        
        expDateTextField.textField.secureText = "01/30"
        expDateTextField.focusOn()
        XCTAssertTrue(expDateTextField.state.isValid)
        XCTAssertFalse(expDateTextField.state.isEmpty)
        
        /// Test today
        let today = Date()
        let formatter = DateFormatter()

        formatter.dateFormat = "yy"
        let todayYY = formatter.string(from: today)

        formatter.dateFormat = "MM"
        let todayMM = formatter.string(from: today)
        
        expDateTextField.textField.secureText = "\(todayMM)/\(todayYY)"
        expDateTextField.focusOn()
        XCTAssertTrue(expDateTextField.state.isValid)
        XCTAssertFalse(expDateTextField.state.isEmpty)
    }
}
