//
//  CardTextFieldTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 04.12.2019.
//  Copyright © 2019 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class CardTextFieldTests: VGSCollectBaseTestCase {

    var form: VGSCollect!
    var cardTextField: VGSCardTextField!
    
    override func setUp() {
			  super.setUp()
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
        XCTAssertNotNil(VGSPaymentCards.CardBrand.unknown.brandIcon)
        XCTAssertNotNil(VGSPaymentCards.CardBrand.amex.brandIcon)
        XCTAssertNotNil(VGSPaymentCards.CardBrand.dinersClub.brandIcon)
        XCTAssertNotNil(VGSPaymentCards.CardBrand.discover.brandIcon)
        XCTAssertNotNil(VGSPaymentCards.CardBrand.jcb.brandIcon)
        XCTAssertNotNil(VGSPaymentCards.CardBrand.maestro.brandIcon)
        XCTAssertNotNil(VGSPaymentCards.CardBrand.mastercard.brandIcon)
        XCTAssertNotNil(VGSPaymentCards.CardBrand.visa.brandIcon)
    }
    
    func testInput() {
        cardTextField.textField.secureText = "4"
        cardTextField.focusOn()
        cardTextField.textField.secureText! += "111111111111111"
        cardTextField.focusOn()
        
        if let state = cardTextField.state as? CardState {
            XCTAssertTrue(state.cardBrand == .visa)
        } else {
            XCTFail("Failt state card text files")
        }
    }
    
    func testLeftRightIcon() {
        let iconSize = CGSize(width: 46, height: 46)
        let cardNum = "41111 1111 1111 1111"
        
        cardTextField.textField.secureText = cardNum
        cardTextField.focusOn()
        cardTextField.cardIconView.layoutSubviews()
        
        // right icon
        cardTextField.cardIconLocation = .right
        cardTextField.cardIconSize = iconSize
        XCTAssertNotNil(cardTextField.cardIconView)
        XCTAssertNotNil(cardTextField.stackView.arrangedSubviews.count > 1)
        XCTAssertTrue(cardTextField.stackView.arrangedSubviews.firstIndex(of: cardTextField.cardIconView) == 1)
        
        // left icon
        cardTextField.cardIconLocation = .left
        cardTextField.cardIconSize = iconSize
        XCTAssertNotNil(cardTextField.cardIconView)
        XCTAssertNotNil(cardTextField.stackView.arrangedSubviews.count > 1)
        XCTAssertTrue(cardTextField.stackView.arrangedSubviews.firstIndex(of: cardTextField.cardIconView) == 0)
    }
    
    func disable_testInput16() {
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
