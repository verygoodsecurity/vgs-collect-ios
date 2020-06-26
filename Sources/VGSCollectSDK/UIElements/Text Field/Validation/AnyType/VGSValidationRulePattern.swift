//
//  VGSValidationRulePattern.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/**
Validate input in scope of matching the pattern(regex).
*/
public struct VGSValidationRulePattern: VGSValidationRuleProtocol {
  
    /// Regex pattern
    public let pattern: String
  
    /// Validation Error
    public let error: VGSValidationError
    
    /// Initialzation
    ///
    /// - Parameters:
    ///   - error:`VGSValidationError` - error on failed validation relust.
    ///   - pattern: regex pattern
    public init(pattern: String, error: VGSValidationError) {
        self.pattern = pattern
        self.error = error
    }
}

extension VGSValidationRulePattern: VGSRuleValidator {
  internal func validate(input: String?) -> Bool {

      return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: input)
  }
}
