//
//  VGSPaymentCards.swift
//  VGSCollectSDK
//
//  Created by Dima on 09.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Class containing supported credit card types
public class VGSPaymentCards {
    
  // MARK: - Enum Cases

  /// Supported card types
  public enum CardType: Equatable {
      
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
      
      /// Not supported card type - "unknown"
      case unknown
    
      case custom(type: String)
    
      /// :nodoc:  Equatable protocol
      public static func ==(lhs: CardType, rhs: CardType) -> Bool {
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
  
    public static var eloCardModel = VGSPaymentCardModel(type: .elo)
    public static var visaElectronCardModel = VGSPaymentCardModel(type: .visaElectron)
    public static var maestroCardModel = VGSPaymentCardModel(type: .maestro)
    public static var forbrugsforeningenCardModel = VGSPaymentCardModel(type: .forbrugsforeningen)
    public static var dankortCardModel = VGSPaymentCardModel(type: .dankort)
    public static var visaCardModel = VGSPaymentCardModel(type: .visa)
    public static var masterCardModel = VGSPaymentCardModel(type: .mastercard)
    public static var amexCardModel = VGSPaymentCardModel(type: .amex)
    public static var hipercardCardModel = VGSPaymentCardModel(type: .hipercard)
    public static var dinersClubCardModel = VGSPaymentCardModel(type: .dinersClub)
    public static var discoverCardModel = VGSPaymentCardModel(type: .discover)
    public static var unionpayCardModel = VGSPaymentCardModel(type: .unionpay)
    public static var jcbCardModel = VGSPaymentCardModel(type: .jcb)
  
    public static var unknownPaymentCardBrandModel = VGSUnknownPaymentCardModel()
  
    /// Array of Available Card Types. Note: the order have impact on which card type should be detected first by  `PaymentCardModel.typePattern`
    public static var availableCardTypes: [VGSPaymentCardModelProtocol] =
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

// MARK: - Attributes
public extension VGSPaymentCards.CardType {
    
    /// String representation of `SwiftLuhn.CardType` enum values.
    var stringValue: String {
        return VGSPaymentCards.availableCardTypes.first(where: { $0.type == self })?.name ?? "unknown"
    }
    
    /// Returns array with valid card number lengths for specific `SwiftLuhn.CardType`
    var cardLengths: [Int] {
      return VGSPaymentCards.availableCardTypes.first(where: { $0.type == self })?.cardNumberLengths ?? VGSPaymentCards.unknownPaymentCardBrandModel.cardNumberLengths
    }
  
}

internal extension VGSPaymentCards.CardType {
  
  /// Returns regex for specific card brand detection
  var defaultTypeDetectRegex: String {
      switch self {
      case .amex:
          return "^3[47]\\d*$"
      case .dinersClub:
          return "^3(?:[689]|(?:0[059]+))\\d*$"
      case .discover:
          return "^(6011|65|64[4-9]|622)\\d*$"
      case .unionpay:
          return "^62\\d*$"
      case .jcb:
          return "^35\\d*$"
      case .mastercard:
          return  "^(5[1-5]|677189)\\d*$|^(222[1-9]|2[3-6]\\d{2,}|27[0-1]\\d|2720)([0-9]{2,})\\d*$"
      case .visaElectron:
          return "^4(026|17500|405|508|844|91[37])\\d*$"
      case .visa:
          return "^4\\d*$"
      case .maestro:
          return "^(5018|5020|5038|6304|6390[0-9]{2,}|67[0-9]{4,})\\d*$"
      case .forbrugsforeningen:
        return "^600\\d*$"
      case .dankort:
        return "^5019\\d*$"
      case .elo:
        return "^(4011(78|79)|43(1274|8935)|45(1416|7393|763(1|2))|50(4175|6699|67[0-7][0-9]|9000)|627780|63(6297|6368)|650(03([^4])|04([0-9])|05(0|1)|4(0[5-9]|3[0-9]|8[5-9]|9[0-9])|5([0-2][0-9]|3[0-8])|9([2-6][0-9]|7[0-8])|541|700|720|901)|651652|655000|655021)\\d*$"
      case .hipercard:
        return "^(384100|384140|384160|606282|637095|637568|60(?!11))\\d*$"
      case .unknown:
         return "^\\d*$"
      case .custom(type: _):
          return ""
      }
  }
  
  var defaultCardLengths: [Int] {
        switch self {
        case .amex:
            return [15]
        case .dinersClub:
            return [14, 16]
        case .discover:
            return [16]
        case .unionpay:
            return [16, 17, 18, 19]
        case .jcb:
            return [16, 17, 18, 19]
        case .mastercard:
            return [16]
        case .visaElectron:
            return [16]
        case .visa:
            return [13, 16, 19]
        case .maestro:
            return [12, 13, 14, 15, 16, 17, 18, 19]
        case .elo:
          return [16]
        case .forbrugsforeningen:
          return [16]
        case .dankort:
          return [16]
        case .hipercard:
          return [14, 15, 16, 17, 18, 19]
        case .unknown:
            return []
        case .custom(type: _):
          return []
        }
    }
  
    var cvcFormatPattern: String {
      var maxLength = 0
      if let cardType = VGSPaymentCards.availableCardTypes.first(where: { $0.type == self }) {
        maxLength = cardType.cvcLengths.max() ?? 0
      } else {
        maxLength = VGSPaymentCards.unknownPaymentCardBrandModel.cvcLengths.max() ?? 0
      }
      return String(repeating: "#", count: maxLength)
    }
  
    var defaultFormatPattern: String {
      switch self {
      case .amex:
        return "#### ###### #####"
      case .dinersClub:
        return "#### ###### ######"
      default:
        return "#### #### #### #### ###"
      }
    }
  
    var defaultName: String {
        switch self {
        case .amex:
            return "American Express"
        case .visa:
            return "Visa"
        case .visaElectron:
            return "Visa Electron"
        case .mastercard:
            return "Mastercard"
        case .discover:
            return "Discover"
        case .dinersClub:
            return "Diners Club"
        case .unionpay:
            return "UnionPay"
        case .jcb:
            return "JCB"
        case .maestro:
            return "Maestro"
        case .elo:
          return "ELO"
        case .forbrugsforeningen:
          return "Forbrugsforeningen"
        case .dankort:
          return "Dankort"
        case .hipercard:
          return "HiperCard"
        case .unknown:
          return "unknown"
        case .custom(type: _):
          return ""
        }
    }
}

internal extension VGSPaymentCards {
    
  //    static var defaultCardModels: [PaymentCardModel] = {
  //      return SwiftLuhn.CardType.allCases.map({ SwiftLuhn.getDefaultCardModel(cardType: $0) })
  //    }()
  //
  //    static func getDefaultCardModel(cardType: SwiftLuhn.CardType) -> PaymentCardModel {
  //      return PaymentCardModel(type: cardType)
  //    }
    
    static func getCardModel(type: VGSPaymentCards.CardType) -> VGSPaymentCardModelProtocol? {
      return availableCardTypes.first(where: { $0.type == type})
    }

    static func getCardType(input: String) -> VGSPaymentCards.CardType {
        for cardType in availableCardTypes {
          let predicate = NSPredicate(format: "SELF MATCHES %@", cardType.typePattern)
          if predicate.evaluate(with: input) == true {
            return cardType.type
          }
        }
        return .unknown
    }
}
