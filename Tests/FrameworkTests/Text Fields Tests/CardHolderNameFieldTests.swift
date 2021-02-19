//
//  CardHolderNameFieldTests.swift
//  FrameworkTests
//
//  Created by Dima on 14.04.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class CardHolderNameFieldTests: VGSCollectBaseTestCase {
    var collector: VGSCollect!
    var cardHolderTextField: VGSTextField!
    
    override func setUp() {
			  super.setUp()
        collector = VGSCollect(id: "tntva5wfdrp")
        
        cardHolderTextField = VGSTextField()
        
        let config = VGSConfiguration(collector: collector, fieldName: "cardHolder")
        config.type = .cardHolderName
        cardHolderTextField.configuration = config
        cardHolderTextField.textField.secureText = "Joe B"
        cardHolderTextField.focusOn()
    }
    
    override func tearDown() {
        cardHolderTextField.configuration = nil
        collector  = nil
        cardHolderTextField = nil
    }
    
    func testAlias() {
        XCTAssertTrue(cardHolderTextField.state.fieldName == "cardHolder")
    }
    
    func testValidNamesReturnsTrue() {
                
        cardHolderTextField.textField.secureText = "Joe"
        cardHolderTextField.focusOn()
        XCTAssertTrue(cardHolderTextField.state.isValid)
        XCTAssertFalse(cardHolderTextField.state.isEmpty)
        
        cardHolderTextField.textField.secureText = "bob bob"
        cardHolderTextField.focusOn()
        XCTAssertTrue(cardHolderTextField.state.isValid)
        XCTAssertFalse(cardHolderTextField.state.isEmpty)
        
        cardHolderTextField.textField.secureText = "A C"
        cardHolderTextField.focusOn()
        XCTAssertTrue(cardHolderTextField.state.isValid)
        XCTAssertFalse(cardHolderTextField.state.isEmpty)
        
        cardHolderTextField.textField.secureText = "A1"
        cardHolderTextField.focusOn()
        XCTAssertTrue(cardHolderTextField.state.isValid)
        XCTAssertFalse(cardHolderTextField.state.isEmpty)
        
        cardHolderTextField.textField.secureText = "0a"
        cardHolderTextField.focusOn()
        XCTAssertTrue(cardHolderTextField.state.isValid)
        XCTAssertFalse(cardHolderTextField.state.isEmpty)
        
        cardHolderTextField.textField.secureText = "'Joe's X,Y.Z-"
        cardHolderTextField.focusOn()
        XCTAssertTrue(cardHolderTextField.state.isValid)
        XCTAssertFalse(cardHolderTextField.state.isEmpty)
    }
    
    func testNotValidNamesReturnsFalse() {
        cardHolderTextField.textField.secureText = ""
        cardHolderTextField.focusOn()
        XCTAssertFalse(cardHolderTextField.state.isValid)
        XCTAssertTrue(cardHolderTextField.state.isEmpty)
        
        cardHolderTextField.textField.secureText = " "
        cardHolderTextField.focusOn()
        XCTAssertFalse(cardHolderTextField.state.isValid)
        XCTAssertFalse(cardHolderTextField.state.isEmpty)
        
        cardHolderTextField.textField.secureText = "."
        cardHolderTextField.focusOn()
        XCTAssertFalse(cardHolderTextField.state.isValid)
        XCTAssertFalse(cardHolderTextField.state.isEmpty)
        
        cardHolderTextField.textField.secureText = "JOHN_B"
        cardHolderTextField.focusOn()
        XCTAssertFalse(cardHolderTextField.state.isValid)
        XCTAssertFalse(cardHolderTextField.state.isEmpty)
        
        cardHolderTextField.textField.secureText = "aaa@gmail.com"
        cardHolderTextField.focusOn()
        XCTAssertFalse(cardHolderTextField.state.isValid)
        XCTAssertFalse(cardHolderTextField.state.isEmpty)
        
        cardHolderTextField.textField.secureText = "%qq"
        cardHolderTextField.focusOn()
        XCTAssertFalse(cardHolderTextField.state.isValid)
        XCTAssertFalse(cardHolderTextField.state.isEmpty)
    }
}
