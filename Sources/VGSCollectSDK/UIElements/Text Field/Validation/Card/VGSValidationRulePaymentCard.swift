//
//  VGSValidationRulePaymentCard.swift
//  VGSCollectSDK
//
//  Created by Dima on 26.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/**
 Validate input in scope of matching supported card brands, available lengths and checkSum algorithms.
 Supports optional validation of cards that are not defined in SDK - `CardBrand.unknown`.
 To edit validation requirments for `CardBrand.unknown` cards in SDK, setup  `VGSPaymentCards.unknown` model attributes.
 */
public struct VGSValidationRulePaymentCard: VGSValidationRuleProtocol {

  /// Validation Error
  public var error: VGSValidationError
  
  /// Turn on/off validation of cards that are not defined in SDK - `CardBrand.unknown`
  public var validateUnknownCardBrand = false

  /// Initialization
  ///
  /// - Parameters:
  ///   - error:`VGSValidationError` - error on failed validation relust.
  public init(error: VGSValidationError) {
    self.error = error
  }

  /// Initialization
  ///
  /// - Parameters:
  ///   - error:`VGSValidationError` - error on failed validation relust.
  ///   - validateUnknownCardBrand: flag that turn on/off validation `CardBrand.unknown`cards.
  public init(error: VGSValidationError, validateUnknownCardBrand: Bool) {
    self.error = error
    self.validateUnknownCardBrand = validateUnknownCardBrand
  }
}

extension VGSValidationRulePaymentCard: VGSRuleValidator {
  
  internal func validate(input: String?) -> Bool {
    
    guard let input = input else {
      return false
    }
    
    let cardBrand = VGSPaymentCards.detectCardBrandFromAvailableCards(input: input)
    
    if cardBrand != .unknown {
      
      /// validate known card brands
      
      return validateCardNumberAsCardBrand(cardBrand, number: input)
      
    } else if  cardBrand == .unknown && validateUnknownCardBrand {
      
      /// validate .unknown brands if there are specific validation rules for undefined brands
      
      return validateCardNumberAsUnknownBrand(number: input)
    }
      
    /// brand is not valid if it's type is .unknown and there are no specific validation rules for .unknown cards
    
    return false
  }
  
  internal func validateCardNumberAsCardBrand(_ cardBrand: VGSPaymentCards.CardBrand, number: String) -> Bool {
    
    /// Check if card brand in available card brands
    guard let cardModel = VGSPaymentCards.getCardModelFromAvailableModels(brand: cardBrand) else {
      return false
    }

    /// Validate defined brands
    guard cardModel.cardNumberLengths.contains(number.count) else {
      return false
    }
    return cardModel.checkSumAlgorithm?.validate(number) ?? true
  }
  
  internal func validateCardNumberAsUnknownBrand(number: String) -> Bool {
    let unknownBrandModel = VGSPaymentCards.unknown
    if !NSPredicate(format: "SELF MATCHES %@", unknownBrandModel.regex).evaluate(with: number) {
        return false
    }
    if !(unknownBrandModel.cardNumberLengths.contains(number.count)) {
      return false
    }
    return unknownBrandModel.checkSumAlgorithm?.validate(number) ?? true
   }
}
