//
//  VGSPaymentCards.swift
//  VGSCollectSDK
//
//  Created by Dima on 09.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Class containing supported payment cards and card brands
public class VGSPaymentCards {
    
  // MARK: - CardBrand Enum Cases

  /// Supported card brands
  public enum CardBrand: Equatable {
      
      /// ELO
      case elo
    
      /// Visa Electron
      case visaElectron
      
      /// Maestro
      case maestro
      
      /// Forbrugsforeningen
      case forbrugsforeningen
    
      /// Dankort
      case dankort
      
      /// Visa
      case visa
      
      /// Mastercard
      case mastercard
      
      /// American Express
      case amex
    
      /// Hipercard
      case hipercard
      
      /// Diners Club
      case dinersClub
      
      /// Discover
      case discover
    
      /// UnionPay
      case unionpay
      
      /// JCB
      case jcb
      
      /// Not supported card brand - "unknown"
      case unknown
    
      /// Custom Card Brand
      case custom(brandName: String)
  }
  
    // MARK: - Payment Card Models
  
    ///  Elo Payment Card Model
    public static var elo = VGSPaymentCardModel(brand: .elo)
    ///  Visa Electron Payment Card Model
    public static var visaElectron = VGSPaymentCardModel(brand: .visaElectron)
    ///  Maestro Payment Card Model
    public static var maestro = VGSPaymentCardModel(brand: .maestro)
    ///  Forbrugsforeningen Payment Card Model
    public static var forbrugsforeningen = VGSPaymentCardModel(brand: .forbrugsforeningen)
    ///  Dankort Payment Card Model
    public static var dankort = VGSPaymentCardModel(brand: .dankort)
    ///  Elo Payment Card Model
    public static var visa = VGSPaymentCardModel(brand: .visa)
    ///  Master Card Payment Card Model
    public static var masterCard = VGSPaymentCardModel(brand: .mastercard)
    ///  Amex Payment Card Model
    public static var amex = VGSPaymentCardModel(brand: .amex)
    ///  Hipercard Payment Card Model
    public static var hipercard = VGSPaymentCardModel(brand: .hipercard)
    ///  DinersClub Payment Card Model
    public static var dinersClub = VGSPaymentCardModel(brand: .dinersClub)
    ///  Discover Payment Card Model
    public static var discover = VGSPaymentCardModel(brand: .discover)
    ///  UnionPay Payment Card Model
    public static var unionpay = VGSPaymentCardModel(brand: .unionpay)
    ///  JCB Payment Card Model
    public static var jcb = VGSPaymentCardModel(brand: .jcb)
  
    // MARK: - Unknown Card Brand Model
  
    ///  Unknown Brand Payment Card Model.  Can be used for specifing cards details when `VGSValidationRulePaymentCard` requires validating `CardBrand.unknown` cards.
    public static var unknown = VGSUnknownPaymentCardModel()
  
  
    // MARK: - Availeble Cards
  
    /// Array of Available Cards. Note: the order have impact on which card brand should be detected first by  `VGSPaymentCardModel.regex`
    public static var availableCards: [VGSPaymentCardModelProtocol] =
                                            [ VGSPaymentCards.elo,
                                              VGSPaymentCards.visaElectron,
                                              VGSPaymentCards.maestro,
                                              VGSPaymentCards.forbrugsforeningen,
                                              VGSPaymentCards.dankort,
                                              VGSPaymentCards.visa,
                                              VGSPaymentCards.masterCard,
                                              VGSPaymentCards.amex,
                                              VGSPaymentCards.hipercard,
                                              VGSPaymentCards.dinersClub,
                                              VGSPaymentCards.discover,
                                              VGSPaymentCards.unionpay,
                                              VGSPaymentCards.jcb ]
    
}

// MARK: - Attributes
public extension VGSPaymentCards.CardBrand {
  
    /// String representation of `VGSPaymentCards.CardBrand` enum values.
    var stringValue: String {
      return VGSPaymentCards.getCardModelFromAvailableModels(brand: self)?.name ?? VGSPaymentCards.unknown.name
    }
    
    /// Returns array with valid card number lengths for specific `VGSPaymentCards.CardBrand`
    var cardLengths: [Int] {
      return VGSPaymentCards.getCardModelFromAvailableModels(brand: self)?.cardNumberLengths ?? VGSPaymentCards.unknown.cardNumberLengths
    }
  
    /// :nodoc:  Equatable protocol
    static func ==(lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.visa, .visa),
           (.elo, .elo),
           (.visaElectron, .visaElectron),
           (.maestro, .maestro),
           (.forbrugsforeningen, .forbrugsforeningen),
           (.dankort, .dankort),
           (.mastercard, .mastercard),
           (.amex, .amex),
           (.hipercard, .hipercard),
           (.dinersClub, .dinersClub),
           (.discover, .discover),
           (.unionpay, .unionpay),
           (.jcb, .jcb),
           (.unknown, .unknown): return true
      case (.custom(let lhsString), .custom(let rhsString)):
        return lhsString == rhsString
      default:
        return false
      }
    }
}


internal extension VGSPaymentCards {
    
    static func getCardModelFromAvailableModels(brand: VGSPaymentCards.CardBrand) -> VGSPaymentCardModelProtocol? {
      return availableCards.first(where: { $0.brand == brand})
    }

    static func detectCardBrandFromAvailableCards(input: String) -> VGSPaymentCards.CardBrand {
        for cardModel in availableCards {
          let predicate = NSPredicate(format: "SELF MATCHES %@", cardModel.regex)
          if predicate.evaluate(with: input) == true {
            return cardModel.brand
          }
        }
        return .unknown
    }
}
