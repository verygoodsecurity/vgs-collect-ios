//
//  LuhnTests.swift
//  FrameworkTests
//


import XCTest
@testable import VGSCollectSDK
@MainActor 
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
