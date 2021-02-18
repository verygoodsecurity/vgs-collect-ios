//
//  PaymentCardsTest.swift
//  VGSCollectSDK
//
//  Created by Dima on 09.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class PaymentCardsTest: VGSCollectBaseTestCase {
  var collector: VGSCollect!
  var cardTextField: VGSTextField!

  override func setUp() {
		  super.setUp()
      collector = VGSCollect(id: "tnt")
      cardTextField = VGSTextField()
      let config = VGSConfiguration(collector: collector, fieldName: "cardNum")
      config.type = .cardNumber
      cardTextField.configuration = config
    
      resetCardBrands()
  }

  override func tearDown() {
    collector = nil
    cardTextField = nil
    resetCardBrands()
  }
  
  func testEditingDefaultBrands() {
    VGSPaymentCards.visa.name =  "cutomized-visa"
    VGSPaymentCards.visa.regex = "^9\\d*$"
    VGSPaymentCards.visa.formatPattern = "####-####-####-###"
    VGSPaymentCards.visa.cardNumberLengths = [15]
    
    cardTextField.setText("911111111111111111111111")
    
    if let state = cardTextField.state as? CardState {
      XCTAssertTrue(state.cardBrand == VGSPaymentCards.CardBrand.visa)
      XCTAssertTrue(state.cardBrand.stringValue == "cutomized-visa")
      XCTAssertTrue(state.cardBrand.cardLengths == [15])
      XCTAssertTrue(state.isValid)
      XCTAssertTrue(state.inputLength == 15)
    } else {
      XCTFail("Failt state card text files")
    }
    
    VGSPaymentCards.visa.checkSumAlgorithm = .none
    VGSPaymentCards.visa.cardNumberLengths = [12]
    cardTextField.setText("900000000012")
    
    if let state = cardTextField.state as? CardState {
      XCTAssertTrue(state.cardBrand == VGSPaymentCards.CardBrand.visa)
      XCTAssertTrue(state.cardBrand.stringValue == "cutomized-visa")
      XCTAssertTrue(state.cardBrand.cardLengths == [12])
      XCTAssertTrue(state.isValid)
      XCTAssertTrue(state.inputLength == 12)
      XCTAssertTrue(state.last4 == "0012")
      XCTAssertTrue(state.bin == "900000")
    } else {
      XCTFail("Failt state card text files")
    }
  }
  
  func testCustomBrandPriority() {
    let customBrandName = "custom-brand-1"
    let customBrand = VGSCustomPaymentCardModel(name: customBrandName,
                                                    regex: VGSPaymentCards.visa.regex,
                                                    formatPattern: "#### #### #### ####",
                                                    cardNumberLengths: [15, 19],
                                                    cvcLengths: [5],
                                                    checkSumAlgorithm: .luhn,
                                                    brandIcon: nil)
    VGSPaymentCards.cutomPaymentCardModels = [customBrand]
    cardTextField.setText("4111111")
    
    if let state = cardTextField.state as? CardState {
      XCTAssertTrue(state.cardBrand == VGSPaymentCards.CardBrand.custom(brandName: customBrandName))
    } else {
      XCTFail("Failt state card text files")
    }
    
    let regex = "^9\\d*$"
    let customBrandName2 = "custom-brand-2"
    let customBrand2 = VGSCustomPaymentCardModel(name: customBrandName2,
                                                    regex: regex,
                                                    formatPattern: "#### #### #### ####",
                                                    cardNumberLengths: [15, 19],
                                                    cvcLengths: [5],
                                                    checkSumAlgorithm: .luhn,
                                                    brandIcon: nil)
    VGSPaymentCards.cutomPaymentCardModels = [customBrand2]
    VGSPaymentCards.visa.regex = regex

    cardTextField.setText("911111")
    
    if let state = cardTextField.state as? CardState {
      XCTAssertTrue(state.cardBrand == VGSPaymentCards.CardBrand.custom(brandName: customBrandName2))
    } else {
      XCTFail("Failt state card text files")
    }
  }
  
  func testCustomBrands() {
    let customBrand1 = VGSCustomPaymentCardModel(name: "custom-brand-1",
                                                 regex: "^911\\d*$",
                                                 formatPattern: "#### #### #### ####",
                                                 cardNumberLengths: [15, 19],
                                                 cvcLengths: [3],
                                                 checkSumAlgorithm: .luhn,
                                                 brandIcon: nil)
    
    let customBrand2 = VGSCustomPaymentCardModel(name: "custom-brand-2",
                                                 regex: "^922\\d*$",
                                                 formatPattern: "#### #### #### ####",
                                                 cardNumberLengths: Array(12...16),
                                                 cvcLengths: [3, 4],
                                                 checkSumAlgorithm: .none,
                                                 brandIcon: nil)
    let customBrands = [customBrand1, customBrand2]
    VGSPaymentCards.cutomPaymentCardModels = customBrands
    cardTextField.setText("9111 1111 1111 111")
    
    if let state = cardTextField.state as? CardState {
      XCTAssertTrue(state.cardBrand == .custom(brandName: "custom-brand-1"))
      XCTAssertTrue(state.cardBrand.stringValue == "custom-brand-1")
      XCTAssertTrue(state.cardBrand.cardLengths == [15, 19])
      XCTAssertTrue(state.isValid)
      XCTAssertTrue(state.inputLength == 15)
    } else {
      XCTFail("Failt state card text files")
    }
    
    cardTextField.setText("92222222222222222222222222")
    
    if let state = cardTextField.state as? CardState {
      XCTAssertTrue(state.cardBrand == .custom(brandName: "custom-brand-2"))
      XCTAssertTrue(state.cardBrand.stringValue == "custom-brand-2")
      XCTAssertTrue(state.cardBrand.cardLengths == Array(12...16))
      XCTAssertTrue(state.isValid)
      XCTAssertTrue(state.inputLength == 16)
    } else {
      XCTFail("Failt state card text files")
    }
  }
  
    func testUnknownBrands() {
      cardTextField.setText("9111 1111 1111 111")
      
      if let state = cardTextField.state as? CardState {
        XCTAssertTrue(state.cardBrand == .unknown)
        XCTAssertFalse(state.isValid)
        XCTAssertTrue(state.inputLength == 15)
      } else {
        XCTFail("Failt state card text files")
      }
      VGSPaymentCards.unknown.formatPattern = "#### #### #### #### #### ####"
      VGSPaymentCards.unknown.cardNumberLengths = [15]
      VGSPaymentCards.unknown.checkSumAlgorithm = .luhn
      
      cardTextField.setText("9111 1111 1111 111")
      if let state = cardTextField.state as? CardState {
        XCTAssertTrue(state.cardBrand == .unknown)
        XCTAssertFalse(state.isValid)
        XCTAssertTrue(state.inputLength == 15)
      } else {
        XCTFail("Failt state card text files")
      }
      
      cardTextField.validationRules = VGSValidationRuleSet(rules: [
        VGSValidationRulePaymentCard.init(error: "some error", validateUnknownCardBrand: true)
      ])
      
      cardTextField.setText("9111 1111 1111 111")
      if let state = cardTextField.state as? CardState {
        XCTAssertTrue(state.cardBrand == .unknown)
        XCTAssertTrue(state.isValid)
        XCTAssertTrue(state.inputLength == 15)
      } else {
        XCTFail("Failt state card text files")
      }
      
      VGSPaymentCards.unknown.cardNumberLengths = Array(12...19)
      VGSPaymentCards.unknown.checkSumAlgorithm = .none
      
      cardTextField.setText("123456789012")
      if let state = cardTextField.state as? CardState {
        XCTAssertTrue(state.cardBrand == .unknown)
        XCTAssertTrue(state.isValid)
        XCTAssertTrue(state.inputLength == 12)
      } else {
        XCTFail("Failt state card text files")
      }
      
      cardTextField.setText("0000 1111 0000 1111 000")
       if let state = cardTextField.state as? CardState {
         XCTAssertTrue(state.cardBrand == .unknown)
         XCTAssertTrue(state.isValid)
         XCTAssertTrue(state.inputLength == 19)
       } else {
         XCTFail("Failt state card text files")
       }
      
      cardTextField.setText("0000 1111 0000 1111 0009")
       if let state = cardTextField.state as? CardState {
         XCTAssertTrue(state.cardBrand == .unknown)
         XCTAssertFalse(state.isValid)
         XCTAssertTrue(state.inputLength == 20)
       } else {
         XCTFail("Failt state card text files")
       }
    }
   
   func testAvailableBrands() {
    XCTAssertTrue(VGSPaymentCards.availableCards.count == VGSPaymentCards.defaultCardModels.count)

    let customBrand1 = VGSCustomPaymentCardModel(name: "custom-brand-1",
                                                 regex: "^9\\d*$",
                                                 formatPattern: "#### #### #### ####",
                                                 cardNumberLengths: [15, 19],
                                                 cvcLengths: [5],
                                                 checkSumAlgorithm: .luhn,
                                                 brandIcon: nil)
    
    let customBrand2 = VGSCustomPaymentCardModel(name: "custom-brand-2",
                                                 regex: "^9\\d*$",
                                                 formatPattern: "#### #### #### ####",
                                                 cardNumberLengths: [15, 19],
                                                 cvcLengths: [5],
                                                 checkSumAlgorithm: .luhn,
                                                 brandIcon: nil)
    let customBrands = [customBrand1, customBrand2]
    VGSPaymentCards.cutomPaymentCardModels = customBrands
    XCTAssertTrue(VGSPaymentCards.availableCards.count == VGSPaymentCards.defaultCardModels.count + customBrands.count)
   }
  
  func resetCardBrands() {
    VGSPaymentCards.elo = VGSPaymentCardModel(brand: .elo)
    VGSPaymentCards.visaElectron = VGSPaymentCardModel(brand: .visaElectron)
    VGSPaymentCards.maestro = VGSPaymentCardModel(brand: .maestro)
    VGSPaymentCards.forbrugsforeningen = VGSPaymentCardModel(brand: .forbrugsforeningen)
    VGSPaymentCards.dankort = VGSPaymentCardModel(brand: .dankort)
    VGSPaymentCards.visa = VGSPaymentCardModel(brand: .visa)
    VGSPaymentCards.masterCard = VGSPaymentCardModel(brand: .mastercard)
    VGSPaymentCards.amex = VGSPaymentCardModel(brand: .amex)
    VGSPaymentCards.hipercard = VGSPaymentCardModel(brand: .hipercard)
    VGSPaymentCards.dinersClub = VGSPaymentCardModel(brand: .dinersClub)
    VGSPaymentCards.discover = VGSPaymentCardModel(brand: .discover)
    VGSPaymentCards.unionpay = VGSPaymentCardModel(brand: .unionpay)
    VGSPaymentCards.jcb = VGSPaymentCardModel(brand: .jcb)
    
    VGSPaymentCards.cutomPaymentCardModels = []
  }
}
