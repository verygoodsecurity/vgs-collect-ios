//
//  VGSValidatior.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal protocol VGSRuleValidator {
    
    func validate(input: String?) -> Bool
}

internal struct VGSValidator {
  
  internal static func validate(input: String?, rule: VGSValidationRuleProtocol) -> [VGSValidationError] {
      
      var ruleSet = VGSValidationRuleSet()
      ruleSet.add(rule: rule)
      return VGSValidator.validate(input: input, rules: ruleSet)
  }
  
  internal static func validate(input: String?, rules: VGSValidationRuleSet) -> [VGSValidationError] {

      let errors = rules.rules
          .filter { !$0.validate(input: input) }
          .map { $0.error }
      
      return errors.isEmpty ? [VGSValidationError]() : errors
  }
}
