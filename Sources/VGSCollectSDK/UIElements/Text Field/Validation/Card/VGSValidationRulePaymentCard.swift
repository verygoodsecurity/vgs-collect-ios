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
    
    let cardType = SwiftLuhn.getCardType(from: input)
    
    if cardType != .unknown {
      
      /// validate defined brands

       guard cardType.cardLengths.contains(input.count) else {
          return false
       }
       return cardType == .unionpay ? true : SwiftLuhn.performLuhnAlgorithm(with: input)
    } else if  cardType == .unknown && validateUnknownCardType {
      
      /// validate .unknown brands if there are specific validation rules for undefined brands
      
      return validateUndefinedCardType(number: input)
    }
      
    /// brand is not valid if it's type is .unknown and there are no specific validation rules for .unknown cards
    
    return false
  }
  
  internal func validateDefinedCardType(type: SwiftLuhn.CardType, number: String) -> Bool {
    guard type.cardLengths.contains(number.count) else {
       return false
    }
    return type == .unionpay ? true : SwiftLuhn.performLuhnAlgorithm(with: number)
  }
  
  internal func validateUndefinedCardType(number: String) -> Bool {
    if !NSPredicate(format: "SELF MATCHES %@", "\\d*$").evaluate(with: number) {
        return false
    }
    if !Array(12...19).contains(number.count) {
      return false
    }
    return SwiftLuhn.performLuhnAlgorithm(with: number)
   }
}

internal struct UndefinedBrandValidationRules {
  
  var lengths: [Int]
  var algorithm: CheckSumAlgorithmType? = nil
  
  func validate(input: String) -> Bool {
     if !lengths.contains(input.count)  {
       return false
     }
     if let alg = algorithm {
      let isValid: Bool
      
      switch alg {
      case .luhn:
        isValid = SwiftLuhn.performLuhnAlgorithm(with: input)
      }
      if !isValid {
        return false
      }
     }
    return true
  }
}

