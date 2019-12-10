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

    func testShowIcon() {
        
        let cardNum = "4111111111111111"
        
        cardTextField.textField.text = cardNum
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
}
