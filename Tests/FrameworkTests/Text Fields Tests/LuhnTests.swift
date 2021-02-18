//
//  LuhnTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 10/3/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class LuhnTests: VGSCollectBaseTestCase {
    var textField: VGSTextField!
    let cardNumer = "4111111111111111"
    
    override func setUp() {
			  super.setUp()
        textField = VGSTextField(frame: .zero)
    }

    override func tearDown() {
        textField = nil
    }

    func test1() {
        XCTAssert(VGSPaymentCards.detectCardBrandFromAvailableCards(input: cardNumer) == .visa)
    }

    func test4() {
      XCTAssertTrue(CheckSumAlgorithmType.luhn.validate(cardNumer))
    }
    
    func test5() {
        let cardBrand = VGSPaymentCards.detectCardBrandFromAvailableCards(input: cardNumer)
        XCTAssert(cardBrand.stringValue.lowercased() == "visa")
    }
}
