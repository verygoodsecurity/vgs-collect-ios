//
//  CardTextFieldTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 04.12.2019.
//  Copyright © 2019 VGS. All rights reserved.
//

import XCTest
@testable import VGSFramework

class CardTextFieldTests: XCTestCase {

    var form: VGSCollect!
    var cardTextField: VGSCardTextField!
    
    override func setUp() {
        form = VGSCollect(id: "tntva5wfdrp")
        let config = VGSConfiguration(collector: form, fieldName: "cardNumber")
        config.type = .cardNumber
        cardTextField = VGSCardTextField()
        cardTextField.configuration = config
    }

    override func tearDown() {
        form = nil
        cardTextField = nil
    }

    func DEL_testShowIcon() {
        
        let cardNum = "4111111111111111"
        
        cardTextField.textField.secureText = cardNum
        cardTextField.focusOn()
        XCTAssertNotNil(cardTextField.cardIconView.image)
    }
    
    func testIconPresent() {
        XCTAssertNotNil(SwiftLuhn.CardType.unknown.brandIcon)
        XCTAssertNotNil(SwiftLuhn.CardType.amex.brandIcon)
        XCTAssertNotNil(SwiftLuhn.CardType.dinersClub.brandIcon)
        XCTAssertNotNil(SwiftLuhn.CardType.discover.brandIcon)
        XCTAssertNotNil(SwiftLuhn.CardType.jcb.brandIcon)
        XCTAssertNotNil(SwiftLuhn.CardType.maestro.brandIcon)
        XCTAssertNotNil(SwiftLuhn.CardType.mastercard.brandIcon)
        XCTAssertNotNil(SwiftLuhn.CardType.mir.brandIcon)
        XCTAssertNotNil(SwiftLuhn.CardType.visa.brandIcon)
        XCTAssertNotNil(SwiftLuhn.CardType.rupay.brandIcon)
    }
    
    func testInput() {
        cardTextField.textField.secureText = "4"
        cardTextField.focusOn()
        cardTextField.textField.secureText! += "1"
        cardTextField.focusOn()
        
        if let state = cardTextField.state as? CardState {
            XCTAssertTrue(state.cardBrand == .visa)
        } else {
            XCTFail("Failt state card text files")
        }
    }
    
    func testInput16() {
        let format14 = "#### ###### ####"
        let format16 = "#### #### #### ####"
        
        cardTextField.textField.secureText = "1234"
        cardTextField.focusOn()
        
        XCTAssertNotNil(cardTextField.textField.formatPattern)
        XCTAssertTrue(cardTextField.textField.formatPattern == format14)
        
        cardTextField.textField.secureText! += "5678"
        cardTextField.focusOn()
        
        XCTAssertNotNil(cardTextField.textField.formatPattern)
        XCTAssertTrue(cardTextField.textField.formatPattern == format14)
        
        cardTextField.textField.secureText! += "9012"
        cardTextField.focusOn()
        
        XCTAssertNotNil(cardTextField.textField.formatPattern)
        XCTAssertTrue(cardTextField.textField.formatPattern == format14)
        
        cardTextField.textField.secureText! += "3456"
        cardTextField.focusOn()
        
        XCTAssertNotNil(cardTextField.textField.formatPattern)
        XCTAssertTrue(cardTextField.textField.formatPattern == format16)
    }
}
