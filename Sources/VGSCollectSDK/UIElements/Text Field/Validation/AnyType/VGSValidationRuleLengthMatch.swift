//
//  VGSValidationRuleLengthMatch.swift
//  VGSCollectSDK
//
//  Created by Dima on 08.07.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/**
Validate input in scope of multiple lengths, e.x.: [16, 19].
*/
public struct VGSValidationRuleLengthMatch: VGSValidationRuleProtocol {
    
    /// Array of valid length ranges
    public let lengths: [Int]
  
    /// Validation Error
    public let error: VGSValidationError

    /// Initialzation
    ///
    /// - Parameters:
    ///   - error:`VGSValidationError` - error on failed validation relust.
    ///   - lengths: array of valid lengths
    public init(lengths: [Int], error: VGSValidationError) {
        self.lengths = lengths
        self.error = error
    }
}

extension VGSValidationRuleLengthMatch: VGSRuleValidator {
  internal func validate(input: String?) -> Bool {

    guard let input = input else {
        return false
    }
    return lengths.contains(input.count)
  }
}
