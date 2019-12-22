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
    public enum CardType: CaseIterable {
        case amex
        case visa
        case mastercard
        case discover
        case dinersClub
        case jcb
        case maestro
        case rupay
        case mir
        case unknown
    }
    
    public enum CardError: Error {
        case unsupported
        case invalid
    }
    
    fileprivate class func regularExpression(for cardType: CardType) -> String {
        switch cardType {
        case .amex:
            return "^3[47][0-9]{5,}$"
        case .dinersClub:
            return "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        case .discover:
            return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        case .jcb:
            return "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        case .mastercard:
            return "^5[1-5][0-9]{5,}|222[1-9][0-9]{3,}|22[3-9][0-9]{4,}|2[3-6][0-9]{5,}|27[01][0-9]{4,}|2720[0-9]{3,}$"
        case .visa:
            return "^4[0-9]{6,}$"
        case .maestro:
            return "^(5018|5020|5038|6304|6759|6761|6763)[0-9]{8,15}$"
        case .rupay:
            return "^6[0-9]{15}$"
        case .mir:
            return "^220[0-9]{13}$"
        default:
            return ""
        }
    }
    
    fileprivate class func suggestionRegularExpression(for cardType: CardType) -> String {
        switch cardType {
        case .amex:
            return "^3[47][0-9]+$"
        case .dinersClub:
            return "^3(?:0[0-5]|[68][0-9])[0-9]+$"
        case .discover:
            return "^6(?:011|5[0-9]{2})[0-9]+$"
        case .jcb:
            return "^(?:2131|1800|35[0-9]{3})[0-9]+$"
        case .mastercard:
            return "^5[1-5][0-9]{5,}|222[1-9][0-9]{3,}|22[3-9][0-9]{4,}|2[3-6][0-9]{5,}|27[01][0-9]{4,}|2720[0-9]{3,}$"
        case .visa:
            return "^4[0-9]+$"
        case .maestro:
            return "^(5018|5020|5038|6304|6759|6761|6763)[0-9]+$"
        case .rupay:
            return "^6[0-9]+$"
        case .mir:
            return "^220[0-9]+$"
        default:
            return ""
        }
    }
    
    class func performLuhnAlgorithm(with cardNumber: String) -> Bool {
                
        let formattedCardNumber = cardNumber.formattedCardNumber()
        
        guard formattedCardNumber.count >= 9 else {
            return false
        }
        
        let originalCheckDigit = formattedCardNumber.last!
        let characters = formattedCardNumber.dropLast().reversed()
        
        var digitSum = 0
        
        for (idx, character) in characters.enumerated() {
            let value = Int(String(character)) ?? 0
            if idx % 2 == 0 {
                var product = value * 2
                
                if product > 9 {
                    product = product - 9
                }
                
                digitSum = digitSum + product
            } else {
                digitSum = digitSum + value
            }
        }
        
        digitSum = digitSum * 9
        
        let computedCheckDigit = digitSum % 10
        
        let originalCheckDigitInt = Int(String(originalCheckDigit))
        let valid = originalCheckDigitInt == computedCheckDigit
        
        return valid
    }
    
    class func cardType(for cardNumber: String, suggest: Bool = false) -> CardType {
        
        var foundCardType: CardType = .unknown
        
        let allCardBrand = CardType.allCases
        
        allCardBrand.forEach { type in
            let regex = suggest ? suggestionRegularExpression(for: type) : regularExpression(for: type)
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            if predicate.evaluate(with: cardNumber.formattedCardNumber()) == true {
                foundCardType = type
            }
        }
        
        return foundCardType
    }
}

public extension SwiftLuhn.CardType {
    func stringValue() -> String {
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
        case .rupay:
            return "Rupay"
        case .mir:
            return "Mir"
        default:
            return "unknown"
        }
    }
