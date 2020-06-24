//
//  VGSValidationRuleCreditCard.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public struct VGSValidationRuleCreditCard: VGSValidationRule {
  
  public var error: VGSValidationError
  public var validationRulesForUndefinedBrand = VGSValidationRuleSet()
  
  public init(error: VGSValidationError) {
    self.error = error
  }
}

 extension VGSValidationRuleCreditCard: VGSRuleValidator {
  
  internal func validate(input: String?) -> Bool {
    
    guard let input = input else {
      return false
    }
    
    let cardType = SwiftLuhn.getCardType(from: input)
    
    /// validate defined brands
    if cardType != .unknown {
       guard cardType.cardLengths.contains(input.count) else {
          return false
       }
       return cardType == .unionpay ? true : SwiftLuhn.performLuhnAlgorithm(with: input)
      
    /// validate .unknown brands if there are specific validation rules for undefined brands
    } else if validationRulesForUndefinedBrand.rules.count > 0 {
      for rule in validationRulesForUndefinedBrand.rules {
        if rule.validate(input: input) == false {
          return false
        }
      }
      
    /// brand is not valid if it's type is .unknown and there are no specific validation rules for .unknown cards
    } else {
      return false
    }
    return true
  }
}
