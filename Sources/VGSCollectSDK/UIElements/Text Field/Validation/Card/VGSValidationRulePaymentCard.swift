//
//  VGSValidationRulePaymentCard.swift
//  VGSCollectSDK
//
//  Created by Dima on 26.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Check Sum Algorithm Types
public enum CheckSumAlgorithmType {
  
  /// Luhn Algorithm
  case luhn
}

extension CheckSumAlgorithmType {
  
  func validate(_ input: String) -> Bool {
    switch self {
    case .luhn:
      return Self.performLuhnAlgorithm(with: input)
    }
  }
}

extension CheckSumAlgorithmType {
  
  /// Validate input number via LuhnAlgorithm algorithm.
  static func performLuhnAlgorithm(with cardNumber: String) -> Bool {
                      
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
}

/**
 Validate input in scope of matching supported card brands, available lengths and checkSum algorithms.
 Supports optional validation of cards that are not defined in SDK - `CardType.unknown`.
 */
public struct VGSValidationRulePaymentCard: VGSValidationRuleProtocol {

  /// Validation Error
  public var error: VGSValidationError
  
  /// Turn on/off validation of cards that are not defined in SDK - `CardType.unknown`
  public var validateUnknownCardType = false

  /// Initialzation
  ///
  /// - Parameters:
  ///   - error:`VGSValidationError` - error on failed validation relust.
  public init(error: VGSValidationError) {
    self.error = error
  }

  /// Initialzation
  ///
  /// - Parameters:
  ///   - error:`VGSValidationError` - error on failed validation relust.
  ///   - validateUnknownCardType: flag that turn on/off validation `CardType.unknown`cards.
  public init(error: VGSValidationError, validateUnknownCardType: Bool) {
    self.error = error
    self.validateUnknownCardType = validateUnknownCardType
  }
}

extension VGSValidationRulePaymentCard: VGSRuleValidator {
  
  internal func validate(input: String?) -> Bool {
    
    guard let input = input else {
      return false
    }
    
    let cardType = SwiftLuhn.getCardType(input: input)
    
    if cardType != .unknown {
      
      /// validate known card brands
      
      return validateCardNumberWithType(cardType: cardType, number: input)
      
    } else if  cardType == .unknown && validateUnknownCardType {
      
      /// validate .unknown brands if there are specific validation rules for undefined brands
      
      return validateCardNumberWithUnknownType(number: input)
    }
      
    /// brand is not valid if it's type is .unknown and there are no specific validation rules for .unknown cards
    
    return false
  }
  
  internal func validateCardNumberWithType(cardType: SwiftLuhn.CardType, number: String) -> Bool {
    
    /// Check if card brand in available card brands
    guard let cardModel = SwiftLuhn.availableCardTypes.first(where: { $0.type == cardType}) else {
      return false
    }

    /// Validate defined brands
    guard cardModel.cardNumberLengths.contains(number.count) else {
      return false
    }
    return cardModel.checkSumAlgorithm?.validate(number) ?? true
  }
  
  internal func validateCardNumberWithUnknownType(number: String) -> Bool {
    let unknownBrandModel = SwiftLuhn.unknownPaymentCardBrandModel
    if !NSPredicate(format: "SELF MATCHES %@", unknownBrandModel.typePattern).evaluate(with: number) {
        return false
    }
    if !(unknownBrandModel.cardNumberLengths.contains(number.count)) {
      return false
    }
    return unknownBrandModel.checkSumAlgorithm?.validate(number) ?? true
   }
}

