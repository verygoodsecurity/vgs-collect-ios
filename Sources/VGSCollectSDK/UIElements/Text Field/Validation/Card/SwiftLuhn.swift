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
        
        /// Visa Electron
        case visaElectron
        
        /// Maestro
        case maestro
        
        /// Visa
        case visa
        
        /// Mastercard
        case mastercard
        
        /// American Express
        case amex
        
        /// Diner's Club
        case dinersClub
        
        /// Discover
        case discover
        
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
        return Self.performLuhnAlgorithm(with: cardNumber)
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
            return "Diner's Club"
        case .jcb:
            return "JCB"
        case .maestro:
            return "Maestro"
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
      case .jcb:
          return "^35\\d*$"
      case .mastercard:
          return "^(5[1-5]|2[2-7])\\d*$"
      case .visaElectron:
          return "^4(026|17500|405|508|844|91[37])\\d*$"
      case .visa:
          return "^4\\d*$"
      case .maestro:
          return "^(5(018|0[23]|[68])|6(39|7))\\d*$"

      case .unknown:
          return ""
      }
  }
}
