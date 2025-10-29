//
//  VGSTextField+patternFormat.swift
//  VGSCollectSDK
//


import Foundation

/// Handle cvc field type
internal extension VGSTextField {
    
  func getCVCValidationRules(cardBrand: VGSPaymentCards.CardBrand) -> VGSValidationRuleSet {
      var cvcLengths = [Int]()
    if let cardModel = VGSPaymentCards.getCardModelFromAvailableModels(brand: cardBrand) {
        cvcLengths = cardModel.cvcLengths
      } else {
        cvcLengths = VGSPaymentCards.unknown.cvcLengths
      }
      return VGSValidationRuleSet(rules: [
        VGSValidationRulePattern(pattern: "\\d*$", error: VGSValidationErrorType.pattern.rawValue),
        VGSValidationRuleLengthMatch(lengths: cvcLengths, error: VGSValidationErrorType.lengthMathes.rawValue)
      ])
    }
}
