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
    
    // MARK: - Enum Cases

    /// Supported card types
    public enum CardType: CaseIterable {
        
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
    }
    
    /// :nodoc:
    public enum CardError: Error {
        case unsupported
        case invalid
    }
    
    /// Complete card number validation.
    /// - Note: cardNumber string should not containt any non-number characters!
    class func validateCardNumber(_ cardNumber: String) -> Bool {
        
        /// check supported card brand
        let cardType = Self.getCardType(from: cardNumber)
        if cardType == .unknown {
            return false
        }
        
        /// check if card number length is valid for specific brand
        guard cardType.cardLengths.contains(cardNumber.count) else {
            return false
        }
        
        /// perform Luhn Algorithm
        return cardType == .unionpay ? true : Self.performLuhnAlgorithm(with: cardNumber)
    }
    
    /// Validate card number via LuhnAlgorithm algorithm.
    class func performLuhnAlgorithm(with cardNumber: String) -> Bool {
                        
        guard cardNumber.count >= 9 else {
            return false
        }
        
        var sum = 0
        let digitStrings = cardNumber.reversed().map { String($0) }

        for tuple in digitStrings.enumerated() {
            if let digit = Int(tuple.element) {
                let odd = tuple.offset % 2 == 1

                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            } else {
                return false
            }
        }
        let valid = sum % 10 == 0
        return valid
    }
    
    ///Returns card type from card number string.
    class func getCardType(from cardNumber: String) -> CardType {
        for cardType in CardType.allCases {
            let predicate = NSPredicate(format: "SELF MATCHES %@", cardType.typeDetectRegex)
            if predicate.evaluate(with: cardNumber) == true {
                return cardType
            }
        }
        return .unknown
    }
}

// MARK: - Attributes
extension SwiftLuhn.CardType {
    
    /// String representation of `SwiftLuhn.CardType` enum values.
    public var stringValue: String {
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
        }
    }
    
    /// Returns array with valid card number lengths for specific `SwiftLuhn.CardType`
    public var cardLengths: [Int] {
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
        }
    }
}

internal extension SwiftLuhn.CardType {
  
  /// Returns regex for specific card brand detection
  var typeDetectRegex: String {
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
      }
  }
}
