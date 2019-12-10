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
        XCTAssertNotNil(SwiftLuhn.CardType.unknown)
        XCTAssertNotNil(SwiftLuhn.CardType.amex)
        XCTAssertNotNil(SwiftLuhn.CardType.dinersClub)
        XCTAssertNotNil(SwiftLuhn.CardType.discover)
        XCTAssertNotNil(SwiftLuhn.CardType.jcb)
        XCTAssertNotNil(SwiftLuhn.CardType.maestro)
        XCTAssertNotNil(SwiftLuhn.CardType.mastercard)
        XCTAssertNotNil(SwiftLuhn.CardType.mir)
        XCTAssertNotNil(SwiftLuhn.CardType.visa)
        XCTAssertNotNil(SwiftLuhn.CardType.rupay)
    }
}
