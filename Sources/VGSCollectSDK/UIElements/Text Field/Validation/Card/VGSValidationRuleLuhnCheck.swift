//
//  VGSValidationRuleLuhnCheck.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/**
Validate input in scope of matching Luhn algorithm.
*/
public struct VGSValidationRuleLuhnCheck: VGSValidationRuleProtocol {
  
  /// Validation Error
  public var error: VGSValidationError

  /// Initialzation
  ///
  /// - Parameters:
  ///   - error:`VGSValidationError` - error on failed validation relust.
  public init(error: VGSValidationError) {
    self.error = error
  }
}

extension VGSValidationRuleLuhnCheck: VGSRuleValidator {
  
  internal func validate(input: String?) -> Bool {
    
    guard let input = input else {
      return false
    }
    return CheckSumAlgorithmType.luhn.validate(input)
  }
}
