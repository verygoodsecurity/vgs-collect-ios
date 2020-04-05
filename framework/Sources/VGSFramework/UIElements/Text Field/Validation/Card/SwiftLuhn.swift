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
        case unknown
    }
    
    public enum CardError: Error {
        case unsupported
        case invalid
    }
    
    fileprivate class func regularExpression(for cardType: CardType) -> String {
        switch cardType {
        case .amex:
            return "^3[4,7][0-9]{13}$"
            
        case .dinersClub:
            return "^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
            
        case .discover:
            return "^6(?:011|[4,5][0-9]{2})[0-9]{12}$"
            
        case .jcb:
            return "^(?:2131|1800|35[0-9]{3})[0-9]{11}$"
            
        case .mastercard:
            return "^((5[1,4,5][0-9]{14})|(222[0-9]{13})|(67[0-9]{14}))$"
            
        case .visa:
            return "^4[0,1,2,4,5,6,9][0-9]{14}$"
            
        case .maestro:
            return "^(50[18,20,38]|6304|67[59,61,63,71])[0-9]{13}$"

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
    
    class func cardType(for cardNumber: String) -> CardType {
        
        var foundCardType: CardType = .unknown
        
        let allCardBrand = CardType.allCases
        
        allCardBrand.forEach { type in
            let regex = regularExpression(for: type)
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            if predicate.evaluate(with: cardNumber.formattedCardNumber()) == true {
                foundCardType = type
            }
        }
        
        return foundCardType
    }
}

public extension SwiftLuhn.CardType {
    var stringValue: String {
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
}
