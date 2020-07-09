//
//  PaymentCardsTest.swift
//  VGSCollectSDK
//
//  Created by Dima on 09.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import XCTest
@testable import VGSCollectSDK

class PaymentCardsTest: XCTestCase {
  var collector: VGSCollect!
  var cardTextField: VGSTextField!

  override func setUp() {
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
       VGSPaymentCards.visaCardModel.typePattern = "^9\\d*$"
       cardTextField.textField.secureText = "91111111"
       cardTextField.focusOn()
       if let state = cardTextField.state as? CardState {
          XCTAssertTrue(state.cardBrand == VGSPaymentCards.CardType.visa)
       } else {
           XCTFail("Failt state card text files")
       }
     }
   
   func testAvailableBrands() {
     XCTAssertTrue(VGSPaymentCards.availableCards.count > 0)
     VGSPaymentCards.availableCards.removeAll()
     XCTAssertTrue(VGSPaymentCards.availableCards.count == 0)

     let customBrand = VGSCustomPaymentCardModel(name: "custom-brand",
                                                 typePattern: "^9\\d*$",
                                                 formatPattern: "#### #### #### ####",
                                                 cardNumberLengths: [15, 19],
                                                 cvcLengths: [5],
                                                 checkSumAlgorithm: .luhn,
                                                 brandIcon: nil)
     VGSPaymentCards.availableCards.append(customBrand)
     XCTAssertTrue(VGSPaymentCards.availableCards.count == 1)
   }
  
  
  func resetCardBrands() {
    VGSPaymentCards.eloCardModel = VGSPaymentCardModel(type: .elo)
    ///  Visa Electron Payment Card Model
    VGSPaymentCards.visaElectronCardModel = VGSPaymentCardModel(type: .visaElectron)
    ///  Maestro Payment Card Model
    VGSPaymentCards.maestroCardModel = VGSPaymentCardModel(type: .maestro)
    ///  Forbrugsforeningen Payment Card Model
    VGSPaymentCards.forbrugsforeningenCardModel = VGSPaymentCardModel(type: .forbrugsforeningen)
    ///  Dankort Payment Card Model
    VGSPaymentCards.dankortCardModel = VGSPaymentCardModel(type: .dankort)
    ///  Elo Payment Card Model
    VGSPaymentCards.visaCardModel = VGSPaymentCardModel(type: .visa)
    ///  Master Card Payment Card Model
    VGSPaymentCards.masterCardModel = VGSPaymentCardModel(type: .mastercard)
    ///  Amex Payment Card Model
    VGSPaymentCards.amexCardModel = VGSPaymentCardModel(type: .amex)
    ///  Hipercard Payment Card Model
    VGSPaymentCards.hipercardCardModel = VGSPaymentCardModel(type: .hipercard)
    ///  DinersClub Payment Card Model
    VGSPaymentCards.dinersClubCardModel = VGSPaymentCardModel(type: .dinersClub)
    ///  Discover Payment Card Model
    VGSPaymentCards.discoverCardModel = VGSPaymentCardModel(type: .discover)
    ///  UnionPay Payment Card Model
    VGSPaymentCards.unionpayCardModel = VGSPaymentCardModel(type: .unionpay)
    ///  JCB Payment Card Model
    VGSPaymentCards.jcbCardModel = VGSPaymentCardModel(type: .jcb)
    
    VGSPaymentCards.availableCards =
                    [ VGSPaymentCards.eloCardModel,
                    VGSPaymentCards.visaElectronCardModel,
                    VGSPaymentCards.maestroCardModel,
                    VGSPaymentCards.forbrugsforeningenCardModel,
                    VGSPaymentCards.dankortCardModel,
                    VGSPaymentCards.visaCardModel,
                    VGSPaymentCards.masterCardModel,
                    VGSPaymentCards.amexCardModel,
                    VGSPaymentCards.hipercardCardModel,
                    VGSPaymentCards.dinersClubCardModel,
                    VGSPaymentCards.discoverCardModel,
                    VGSPaymentCards.unionpayCardModel,
                    VGSPaymentCards.jcbCardModel ]
  }
}
