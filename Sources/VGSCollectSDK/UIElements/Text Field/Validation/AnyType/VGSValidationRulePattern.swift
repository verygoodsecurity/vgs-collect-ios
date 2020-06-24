//
//  VGSValidationRulePattern.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public struct VGSValidationRulePattern: VGSValidationRule {
  
//    public let validationType: ValidationType = .pattern
    public let pattern: String
    public let error: VGSValidationError
    
    public init(pattern: String, error: VGSValidationError) {
        self.pattern = pattern
        self.error = error
    }
    
//    public init(pattern: ValidationPattern, error: VGSError) {
//
//        self.init(pattern: pattern.pattern, error: error)
//    }


}

extension VGSValidationRulePattern: VGSRuleValidator {
  internal func validate(input: String?) -> Bool {

      return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: input)
  }
}
