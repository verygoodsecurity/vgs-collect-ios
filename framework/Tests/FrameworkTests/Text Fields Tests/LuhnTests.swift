//
//  LuhnTests.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 10/3/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import XCTest
@testable import VGSFramework

class LuhnTests: XCTestCase {
    var textField: VGSTextField!
    let cardNumer = "4111111111111111"
    
    override func setUp() {
        textField = VGSTextField(frame: .zero)
    }

    override func tearDown() {
        textField = nil
    }

    func test0() {
        XCTAssertTrue(cardNumer.isValidCardNumber())
    }

    func test1() {
        XCTAssert(cardNumer.cardType() == .visa)
    }
    
    func test2() {
        XCTAssert(SwiftLuhn.cardType(for: cardNumer) == .visa)
    }
    
    func test3() {
        XCTAssert(cardNumer.suggestedCardType() == .visa)
    }
    
    func test4() {
        XCTAssertTrue(SwiftLuhn.performLuhnAlgorithm(with: cardNumer))
    }
    
    func test5() {
        XCTAssert(cardNumer.cardType().stringValue().lowercased() == "visa")
    }
    
    func test6() {
        let formatedText = "4111 1111 1111 1111".formattedCardNumber()
        
        XCTAssert(formatedText == cardNumer)
    }
}
