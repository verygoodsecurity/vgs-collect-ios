//
//  String+SwiftLuhn.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 9/16/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

public extension String {
    func isValidCardNumber() -> Bool {
        let isLuhnTrue = SwiftLuhn.performLuhnAlgorithm(with: self)
        let isType = cardType() != .unknown
        return isLuhnTrue && isType
    }
    
    func cardType() -> SwiftLuhn.CardType {
        let cardType = SwiftLuhn.cardType(for: self)
        return cardType
    }
    func suggestedCardType() -> SwiftLuhn.CardType {
        let cardType = SwiftLuhn.cardType(for: self)
        return cardType
    }
    
    func formattedCardNumber() -> String {
        let numbersOnlyEquivalent = replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: nil)
        return numbersOnlyEquivalent.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
