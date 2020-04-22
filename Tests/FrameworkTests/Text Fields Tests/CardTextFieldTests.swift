//
//  CardTextFieldTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 04.12.2019.
//  Copyright © 2019 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

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
        XCTAssertNotNil(SwiftLuhn.CardType.visa.brandIcon)
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
        let padding = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 12)
        
        cardTextField.padding = padding
        
        // right icon
        cardTextField.sideCardIcon = .right(size: iconSize)
        
        XCTAssertNotNil(cardTextField.cardIconView)
        XCTAssert(cardTextField.padding.left == padding.left)
        XCTAssert(cardTextField.padding.right == padding.right + iconSize.width)
        
        XCTAssert(cardTextField.originalLeftPadding == -1)
        XCTAssert(cardTextField.originalRightPadding == padding.right)
        
        XCTAssertNil(cardTextField.textField.leftView)
        XCTAssertNotNil(cardTextField.textField.rightView)

//        XCTAssert(cardTextField.cardIconView.frame.size == iconSize)
        
        // left icon
        cardTextField.sideCardIcon = .left(size: iconSize)
        
        XCTAssertNotNil(cardTextField.cardIconView)
        XCTAssert(cardTextField.padding.left == padding.left + iconSize.width)
        XCTAssert(cardTextField.padding.right == padding.right)
        
        XCTAssert(cardTextField.originalLeftPadding == padding.left)
        XCTAssert(cardTextField.originalRightPadding == -1)
        
        XCTAssertNotNil(cardTextField.textField.leftView)
        XCTAssertNil(cardTextField.textField.rightView)
        
//        XCTAssert(cardTextField.cardIconView.frame.size == iconSize)
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
