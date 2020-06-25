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
  internal var undefinedBrandValidationRules: UndefinedBrandValidationRules?
  
  public init(error: VGSValidationError) {
    self.error = error
  }
  
  public mutating func addUndefinedBrandValidation(minLength: UInt, maxLength: UInt, algorithm: CheckSumAlgorithmType? = nil) {
    self.undefinedBrandValidationRules = UndefinedBrandValidationRules(minLength: minLength, maxLength: maxLength, algorithm: algorithm)
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
    } else if let undefinedBrandRules = undefinedBrandValidationRules {
      
      /// validate .unknown brands if there are specific validation rules for undefined brands
      
      return undefinedBrandRules.validate(input: input)
    } else {
      
      /// brand is not valid if it's type is .unknown and there are no specific validation rules for .unknown cards
      return false
    }
    return true
  }
}

internal struct UndefinedBrandValidationRules {
  
  var minLength: UInt
  var maxLength:UInt
  var algorithm: CheckSumAlgorithmType? = nil
  
  func validate(input: String) -> Bool {
     if input.count < minLength {
          return false
     }
     if input.count > maxLength {
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
