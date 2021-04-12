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
        VGSPaymentCards.validCardBrands = nil
    }
    
    func testCardBrandDetectionReturnsTrue() {
        let allBrands = VGSPaymentCards.availableCardBrands
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
        let allBrands = VGSPaymentCards.availableCardBrands
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
        let allBrands = VGSPaymentCards.availableCardBrands
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
        let allBrands = VGSPaymentCards.availableCardBrands
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
        let allBrands = VGSPaymentCards.availableCardBrands.filter { $0.brand != .unionpay }
        
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
  
    func testCustomizedValidBrands() {
      
      /// Create custom brand model
      let customBrandModel = VGSCustomPaymentCardModel(name: "custom-brand",
                                                 regex: "^91\\d*$",
                                                 formatPattern: "#### #### #### ####",
                                                 cardNumberLengths: [15],
                                                 cvcLengths: [5],
                                                 checkSumAlgorithm: .luhn,
                                                 brandIcon: nil)
      
      /// Set valid card brands
      let validCardBrandModels: [VGSPaymentCardModelProtocol] = [VGSPaymentCards.visaElectron, VGSPaymentCards.visa, customBrandModel, VGSPaymentCards.masterCard, VGSPaymentCards.amex]
      VGSPaymentCards.validCardBrands = validCardBrandModels
      
      /// Check correct valid card brands setup
      XCTAssert(VGSPaymentCards.validCardBrands?.count == validCardBrandModels.count, "VGSPaymentCards.validCardBrand array is not updated!!!")
      
      /// Array of valid card brands enum
      let validBrands = validCardBrandModels.map { $0.brand }

      /// Test cards - all card brands
      var testBrandModels = VGSPaymentCards.defaultCardModels
      
      /// Add custom brand to testModels
      testBrandModels.insert(customBrandModel, at: 0)

      for model in testBrandModels {
        
        /// Check if brand in valid brands
        let isValidModel = validBrands.contains(model.brand)
        
        /// Get array of test cad numbers for specific brands
        let testCardNumbers = (model.brand == customBrandModel.brand) ? ["9111 1111 1111 111"] : model.brand.cardNumbers
        
        for cardNumber in testCardNumbers {
          cardTextField.setText(cardNumber)
        
          guard let state = cardTextField.state as? CardState else {
            XCTFail("Can't cast to CardState")
            return
          }
          XCTAssertTrue(state.isValid == isValidModel, "\(cardNumber) state.isValid = \(state.isValid), but should be \(isValidModel) for \(state.cardBrand)")
          if isValidModel {
            XCTAssertTrue(state.cardBrand == model.brand, "\(state.cardBrand) - is not detected or wron-detected, should be \(model.brand)")
          } else {
            XCTAssertTrue(state.cardBrand == .unknown, "\(state.cardBrand) - is detected, but should be unknown")
          }
        }
      }
    }

    func testCustomizedValidBrandsSetEmpty() {
      /// Set that all default card brands should be ignored
      VGSPaymentCards.validCardBrands = []
      
      /// Get test cards for each default brands
      let testCards = VGSPaymentCards.defaultCardModels.map {$0.brand.cardNumbers}.reduce([], +)

      for card in testCards {
        cardTextField.setText(card)
        
        guard let state = cardTextField.state as? CardState else {
          XCTFail("Can't cast to CardState")
          return
        }
        XCTAssertFalse(state.isValid, "\(card) - is valid card but not included to valid card brands")
        XCTAssertTrue(state.cardBrand == .unknown, "\(state.cardBrand) - is defined, not included to valid card brands")
      }
    }
  
  func testCustomizedValidBrandsDetectionPriority() {
    
    let testCardNumber = "4111 1111 1111 1111"
    /// Create custom brand model that have regex similar to Visa
    let customBrandModel = VGSCustomPaymentCardModel(name: "custom-brand",
                                               regex: "^41\\d*$",
                                               formatPattern: "#### #### #### ####",
                                               cardNumberLengths: [16],
                                               cvcLengths: [5],
                                               checkSumAlgorithm: .luhn,
                                               brandIcon: nil)
    
    /// Set valid card brands - Visa first
    VGSPaymentCards.validCardBrands = [ VGSPaymentCards.visa, customBrandModel]

    cardTextField.setText(testCardNumber)
    guard let state1 = cardTextField.state as? CardState else {
      XCTFail("Can't cast to CardState")
      return
    }
    XCTAssertTrue(state1.cardBrand == .visa)
    
    /// Set valid card brands - customBrandModel first
    VGSPaymentCards.validCardBrands = [customBrandModel, VGSPaymentCards.visa]
    
    cardTextField.setText(testCardNumber)
    
    guard let state2 = cardTextField.state as? CardState else {
      XCTFail("Can't cast to CardState")
      return
    }
    XCTAssertTrue(state2.cardBrand == customBrandModel.brand)
  }
}
