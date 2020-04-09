//
//  MasterCardBrandTest.swift
//  FrameworkTests
//
//  Created by Vitalii Obertynskyi on 06.04.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSFramework

class CardBrandTest: XCTestCase {
    var storage: VGSCollect!
    var cardTextField: VGSTextField!
    
    override func setUp() {
        storage = VGSCollect(id: "123")
        cardTextField = VGSTextField()
        
        let config = VGSConfiguration(collector: storage, fieldName: "cardNum")
        config.type = .cardNumber
        config.formatPattern = nil
        cardTextField.configuration = config
    }

    override func tearDown() {
        storage = nil
        cardTextField = nil
    }
    
    func testCardBrandDetectionReturnsTrue() {
        let allBrands = SwiftLuhn.CardType.allCases
        allBrands.forEach { brand in
            let numbers = brand.cardNumbers
            numbers.forEach { number in
                cardTextField.textField.secureText = number
                guard let state = cardTextField.state as? CardState else {
                    XCTFail("Guard fail")
                    return
                }
                XCTAssert(state.cardBrand == brand, "Card number \(number) for brand \(brand) fail")
            }
        }
    }
    
    func testCardBrandDetectionByFirstDigitsReturnsTrue() {
        let allBrands = SwiftLuhn.CardType.allCases
        allBrands.forEach { brand in
            let numbers = brand.cardNumbers
            numbers.forEach { number in
                let startIndex = (brand == .mastercard || brand == .maestro) ? 7 : 4
                let digitsCount = Int.random(in: startIndex...11)
                let input = String(number.prefix(digitsCount))
                cardTextField.textField.secureText = input
                guard let state = cardTextField.state as? CardState else {
                    XCTFail("Guard fail")
                    return
                }
                XCTAssert(state.cardBrand == brand, "Card number \(number), first digits \(input), for brand \(brand) fail")
            }
        }
    }
    
    func testValidCardsValidationReturnsTrue() {
        let allBrands = SwiftLuhn.CardType.allCases
        allBrands.forEach { brand in
            let numbers = brand.cardNumbers
            numbers.forEach { number in
                cardTextField.textField.secureText = number
                guard let state = cardTextField.state as? CardState else {
                    XCTFail("Guard fail")
                    return
                }

                XCTAssert(state.isValid == true, "Card number \(number) for brand \(brand) fail")
            }
        }
    }
    
    func testNotFullCardsValidationReturnsFalse() {
        let allBrands = SwiftLuhn.CardType.allCases
        allBrands.forEach { brand in
            let numbers = brand.cardNumbers
            for number in numbers {
                if number.count > 16 {
                    continue
                }
                
                let digitsCount = Int.random(in: 1...6)
                
                let input = String(number.prefix(number.count - digitsCount))
                cardTextField.textField.secureText = input
                guard let state = cardTextField.state as? CardState else {
                    XCTFail("Guard fail")
                    return
                }
                XCTAssert(state.isValid == false, "Card number \(number), first digits \(input), for brand \(brand) fail")
            }
        }
    }
    
    func testNotValidCardsValidationReturnsFalse() {
        let allBrands = SwiftLuhn.CardType.allCases
        allBrands.forEach { brand in
            let numbers = brand.cardNumbers
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
                XCTAssert(state.isValid == false, "Not Valid Card number \(number), first digits \(input), for brand \(brand) fail")
            }
        }
    }
    
    func testSpecificNotValidCardsValidationReturnsFalse() {
        let numbers = SwiftLuhn.specificNotValidCardNumbers
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
