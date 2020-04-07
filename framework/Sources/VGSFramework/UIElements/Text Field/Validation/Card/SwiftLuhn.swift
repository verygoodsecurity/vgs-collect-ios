//
//  SwiftLuhn.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 9/16/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public class SwiftLuhn {
    
    /// Supported card types
    public enum CardType: CaseIterable {
        case amex
        case visa
        case mastercard
        case discover
        case dinersClub
        case jcb
        case maestro
        case unknown
    }
    
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
        guard cardType.possibleLengths.contains(cardNumber.count) else {
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

extension SwiftLuhn.CardType {
    
    public var stringValue: String {
        switch self {
        case .amex:
            return "American Express"
        case .visa:
            return "Visa"
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
        default:
            return "unknown"
        }
    }
    
    internal var typeDetectRegex: String {
        switch self {
        case .amex:
            return "^3[4,7]\\d*$"
        case .dinersClub:
            return "^(36|38|30[0-5])\\d*$"
        case .discover:
            return "^(6011|65|64[4-9]|622)\\d*$"
        case .jcb:
            return "^35\\d*$"
        case .mastercard:
            return "^(5[1-5][0-9]{4,}|677189)|^(222[1-9]|2[3-6]{2,}|27[0-1]|2720)([0-9]{2,})+$"
        case .visa:
            return "^4[0,1,2,4,5,6,9]\\d*$"
        case .maestro:
            return "(5018|5020|5038|6304|6390[0-9]{2,}|67[0-9]{4,})\\d*$"
        case .unknown:
            return ""
        }
    }
    
    internal var possibleLengths: [Int] {
        switch self {
        case .amex:
            return [15]
        case .dinersClub:
            return [14]
        case .discover:
            return [16]
        case .jcb:
            return [16, 17, 18, 19]
        case .mastercard:
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
