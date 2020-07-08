//
//  SwiftLuhn.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 9/16/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Class containing supported credit card types
public class SwiftLuhn {
  
    public static var eloModel = PaymentCardModel(type: .elo)
    public static var visaElectronModel = PaymentCardModel(type: .visaElectron)
    public static var maestroModel = PaymentCardModel(type: .maestro)
    public static var forbrugsforeningenModel = PaymentCardModel(type: .forbrugsforeningen)
    public static var dankortModel = PaymentCardModel(type: .dankort)
    public static var visaModel = PaymentCardModel(type: .visa)
    public static var masterCardModel = PaymentCardModel(type: .mastercard)
    public static var amexModel = PaymentCardModel(type: .amex)
    public static var hipercardModel = PaymentCardModel(type: .hipercard)
    public static var discoverModel = PaymentCardModel(type: .discover)
    public static var unionpayModel = PaymentCardModel(type: .unionpay)
    public static var jcbModel = PaymentCardModel(type: .jcb)
  
    public static var unknownPaymentCardBrandModel = UnknownPaymentCardModel()
  
    public static var availableCardTypes: [PaymentCardModelProtocol] =
                                            [
                                              SwiftLuhn.eloModel,
                                              SwiftLuhn.visaElectronModel,
                                              SwiftLuhn.maestroModel,
                                              SwiftLuhn.forbrugsforeningenModel,
                                              SwiftLuhn.dankortModel,
                                              SwiftLuhn.visaModel,
                                              SwiftLuhn.masterCardModel,
                                              SwiftLuhn.amexModel,
                                              SwiftLuhn.hipercardModel,
                                              SwiftLuhn.discoverModel,
                                              SwiftLuhn.unionpayModel,
                                              SwiftLuhn.jcbModel]
  
//    static var defaultCardModels: [PaymentCardModel] = {
//      return SwiftLuhn.CardType.allCases.map({ SwiftLuhn.getDefaultCardModel(cardType: $0) })
//    }()
//
//    static func getDefaultCardModel(cardType: SwiftLuhn.CardType) -> PaymentCardModel {
//      return PaymentCardModel(type: cardType)
//    }
  
    internal static func getCardType(input: String) -> SwiftLuhn.CardType {
      for cardType in availableCardTypes {
        let predicate = NSPredicate(format: "SELF MATCHES %@", cardType.typePattern)
        if predicate.evaluate(with: input) == true {
          return cardType.type
        }
      }
      return .unknown
    }
    
    
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
      
        public static func ==(lhs: CardType, rhs: CardType) -> Bool {
          switch (lhs, rhs) {
          case (.visa, .visa): return true
          case (.elo, .elo): return true
          case (.visaElectron, .visaElectron): return true
          case (.maestro, .maestro): return true
          case (.forbrugsforeningen, .forbrugsforeningen): return true
          case (.dankort, .dankort): return true
          case (.mastercard, .mastercard): return true
          case (.amex, .amex): return true
          case (.hipercard, .hipercard): return true
          case (.dinersClub, .dinersClub): return true
          case (.discover, .discover): return true
          case (.unionpay, .unionpay): return true
          case (.jcb, .jcb): return true
          case (.unknown, .unknown): return true
          case (.custom(let lhsString), .custom(let rhsString)):
            return lhsString == rhsString
          default:
            return false
          }
        }
    }
}

// MARK: - Attributes
extension SwiftLuhn.CardType {
    
    /// String representation of `SwiftLuhn.CardType` enum values.
    public var stringValue: String {
        return SwiftLuhn.availableCardTypes.first(where: { $0.type == self })?.name ?? "unknown"
    }
  
    internal var defaultName: String {
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
        case .custom(type: let name):
          return name
        }
    }
    
    /// Returns array with valid card number lengths for specific `SwiftLuhn.CardType`
    public var cardLengths: [Int] {
      return SwiftLuhn.availableCardTypes.first(where: { $0.type == self })?.cardNumberLengths ?? []
    }
  
    internal var defaultCardLengths: [Int] {
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
}

internal extension SwiftLuhn.CardType {
  
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
          return ""
      case .custom(type: _):
        return ""
      }
  }
}

public protocol PaymentCardModelProtocol {
  var type: SwiftLuhn.CardType { get }
  var name: String { get set }
  var typePattern: String { get set }
  var cardNumberLengths: [Int] { get set }
  var cvcLengths: [Int] { get set }
  var checkSumAlgorithm: CheckSumAlgorithmType? { get set }
  var brandIcon: UIImage? { get set }
}

public struct PaymentCardModel: PaymentCardModelProtocol {
  
  public let type: SwiftLuhn.CardType
  public var name: String
  public var typePattern: String
  public var cardNumberLengths: [Int]
  public var cvcLengths: [Int]
  public var checkSumAlgorithm: CheckSumAlgorithmType?
  public var brandIcon: UIImage?
  
  init(type: SwiftLuhn.CardType) {
    self.type = type
    self.name = type.defaultName
    self.typePattern = type.defaultTypeDetectRegex
    self.cardNumberLengths = type.defaultCardLengths
    self.cvcLengths = [3]
    self.checkSumAlgorithm = .luhn
    self.brandIcon = type.defaultBrandIcon
  }
}

public struct CustomPaymentCardModel: PaymentCardModelProtocol {
  public let type: SwiftLuhn.CardType
  public var name: String
  public var typePattern: String
  public var cardNumberLengths: [Int]
  public var cvcLengths: [Int]
  public var checkSumAlgorithm: CheckSumAlgorithmType?
  public var brandIcon: UIImage?
  
  public init(name: String, typePattern: String, cardNumberLengths: [Int], cvcLengths: [Int], checkSumAlgorithm: CheckSumAlgorithmType? = .luhn, brandIcon: UIImage?) {
    self.type = .custom(type: name)
    self.name = name
    self.typePattern = typePattern
    self.cardNumberLengths = cardNumberLengths
    self.cvcLengths = cvcLengths
    self.checkSumAlgorithm = checkSumAlgorithm
    self.brandIcon = brandIcon
  }
}

public struct UnknownPaymentCardModel {
  internal var typePattern: String = "\\d*$"
  public var cardNumberLengths: [Int] = Array(16...19)
  public var cvcLengths: [Int] = [3]
  public var checkSumAlgorithm: CheckSumAlgorithmType? = .luhn
  public var brandIcon: UIImage? = SwiftLuhn.CardType.unknown.brandIcon
  
  public init() {}
  
  public init(cardNumberLengths: [Int], cvcLengths: [Int], checkSumAlgorithm: CheckSumAlgorithmType? = .luhn, brandIcon: UIImage?) {
    self.cardNumberLengths = cardNumberLengths
    self.cvcLengths = cvcLengths
    self.checkSumAlgorithm = checkSumAlgorithm
    self.brandIcon = brandIcon
  }
}
