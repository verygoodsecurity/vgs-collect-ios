//
//  LuhnTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 10/3/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class LuhnTests: XCTestCase {
    var textField: VGSTextField!
    let cardNumer = "4111111111111111"
    
    override func setUp() {
        textField = VGSTextField(frame: .zero)
    }

    override func tearDown() {
        textField = nil
    }

    func test1() {
        XCTAssert(SwiftLuhn.getCardType(input: cardNumer) == .visa)
    }

    func test4() {
      XCTAssertTrue(CheckSumAlgorithmType.luhn.validate(cardNumer))
    }
    
    func test5() {
        let cardType = SwiftLuhn.getCardType(input: cardNumer)
        XCTAssert(cardType.stringValue.lowercased() == "visa")
    }
    
    func test6() {
        let formatedText = "4111 1111 1111 1111".numbersString
        XCTAssert(formatedText == cardNumer)
    }
}
