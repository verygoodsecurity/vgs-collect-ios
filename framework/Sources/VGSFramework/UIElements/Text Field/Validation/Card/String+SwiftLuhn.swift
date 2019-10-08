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
        return SwiftLuhn.performLuhnAlgorithm(with: self)
    }
    
    func cardType() -> SwiftLuhn.CardType {
        let cardType = SwiftLuhn.cardType(for: self)
        return cardType
    }
    func suggestedCardType() -> SwiftLuhn.CardType {
        let cardType = SwiftLuhn.cardType(for: self, suggest: true)
        return cardType
    }
    
    func formattedCardNumber() -> String {
        let numbersOnlyEquivalent = replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: nil)
        return numbersOnlyEquivalent.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
