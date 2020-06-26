//
//  VGSValidationRuleCreditCard.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public enum CheckSumAlgorithmType {
  case luhn
}

public struct VGSValidationRuleCreditCard: VGSValidationRule {

  public var error: VGSValidationError
  public var validateUnknownCardType = false

  public init(error: VGSValidationError) {
    self.error = error
  }

  public init(error: VGSValidationError, validateUnknownCardType: Bool) {
    self.error = error
    self.validateUnknownCardType = validateUnknownCardType
  }
}

extension VGSValidationRuleCreditCard: VGSRuleValidator {
  
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
    if !NSPredicate(format: "SELF MATCHES %@", "[0-9]{6,}").evaluate(with: number) {
        return false
    }
    if ![12, 13, 14, 15, 16, 19].contains(number.count) {
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
