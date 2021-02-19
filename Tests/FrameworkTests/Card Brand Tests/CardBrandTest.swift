//
//  MasterCardBrandTest.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 06.04.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class CardBrandTest: VGSCollectBaseTestCase {
    var storage: VGSCollect!
    var cardTextField: VGSTextField!
    
    override func setUp() {
			  super.setUp()
        storage = VGSCollect(id: "123")
        cardTextField = VGSTextField()
        
        let config = VGSConfiguration(collector: storage, fieldName: "cardNum")
        config.type = .cardNumber
        config.formatPattern = ""
        cardTextField.configuration = config
    }

    override func tearDown() {
        storage = nil
        cardTextField = nil
    }
    
    func testCardBrandDetectionReturnsTrue() {
        let allBrands = VGSPaymentCards.availableCards
        allBrands.forEach { card in
          let numbers = card.brand.cardNumbers
            numbers.forEach { number in
                cardTextField.textField.secureText = number
                guard let state = cardTextField.state as? CardState else {
                    XCTFail("Guard fail")
                    return
                }
              XCTAssert(state.cardBrand == card.brand, "Card number \(number) for brand \(card.brand) fail")
            }
        }
    }
    
    func testCardBrandDetectionByFirstDigitsReturnsTrue() {
        let allBrands = VGSPaymentCards.availableCards
        allBrands.forEach { card in
          let numbers = card.brand.firsDigitsInCardNumber
            numbers.forEach { number in
                cardTextField.textField.secureText = number
                guard let state = cardTextField.state as? CardState else {
                    XCTFail("Guard fail")
                    return
                }
              XCTAssert(state.cardBrand == card.brand, "First digits \(number), for brand \(card.brand) fail")
            }
        }
    }
    
    func testValidCardsValidationReturnsTrue() {
        let allBrands = VGSPaymentCards.availableCards
        allBrands.forEach { card in
            let numbers = card.brand.cardNumbers
            numbers.forEach { number in
                cardTextField.textField.secureText = number
                guard let state = cardTextField.state as? CardState else {
                    XCTFail("Guard fail")
                    return
                }

                XCTAssert(state.isValid == true, "Card number \(number) for brand \(card.brand) fail")
            }
        }
    }
    
    func testNotFullCardsValidationReturnsFalse() {
        let allBrands = VGSPaymentCards.availableCards
        allBrands.forEach { card in
          let numbers = card.brand.cardNumbers
            for number in numbers {
                /// there are 19 digits numbers that detected as valid by Luhn algorithms when there are 16-19 digits
                if number.count > 16 {
                    continue
                }
                                
                let input = String(number.prefix(number.count - 1))
                cardTextField.textField.secureText = input
                guard let state = cardTextField.state as? CardState else {
                    XCTFail("Guard fail")
                    return
                }
                XCTAssert(state.isValid == false, "Card number \(number), first digits \(input), for brand \(card.brand) fail")
            }
        }
    }
    
    func testNotValidCardsValidationReturnsFalse() {
        let allBrands = VGSPaymentCards.availableCards.filter { $0.brand != .unionpay }
        
        allBrands.forEach { card in
            let numbers = card.brand.cardNumbers
            numbers.forEach { number in
                /// replace rendom number in card. We skip first digits that detect brand since brand used for validation too.
                let lastIndex = number.count > 16 ? 16 : number.count
                let replaceCharIndex = Int.random(in: 7...lastIndex)
                let prefix = number.prefix(replaceCharIndex)
                let numToChange = Int(String(prefix.last!))!
                var randomNums = Array(0...9)
                randomNums.remove(at: numToChange)
                let newNum = randomNums.randomElement()!
                let input = number.prefix(replaceCharIndex - 1) + "\(newNum)" + number.dropFirst(replaceCharIndex)
                cardTextField.textField.secureText = String(input)
                guard let state = cardTextField.state as? CardState else {
                    XCTFail("Guard fail")
                    return
                }
              XCTAssert(state.isValid == false, "Not Valid Card number \(number), first digits \(input), for brand \(card.brand) fail")
            }
        }
    }
    
    func testSpecificNotValidCardsValidationReturnsFalse() {
        let numbers = VGSPaymentCards.specificNotValidCardNumbers
        numbers.forEach { number in
            cardTextField.textField.secureText = number
            guard let state = cardTextField.state as? CardState else {
                XCTFail("Guard fail")
                return
            }
            XCTAssert(state.isValid == false, "Specific Not Valid Card number \(number) validation fail")
            XCTAssert(state.last4.isEmpty == true, "Specific Not Valid Card number \(number), state.last4.isEmpty == true fail")
            XCTAssert(state.bin.isEmpty == true, "Specific Not Valid Card number \(number), tate.bin.isEmpty == true fail")
        }
    }
}
