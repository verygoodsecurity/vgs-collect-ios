//
//  VGSValidationRuleLength.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public struct VGSValidationRuleLength: VGSValidationRule {
    
    public let min: Int
    public let max: Int
    public let error: VGSValidationError

    public init(min: Int = 0, max: Int = Int.max, error: VGSValidationError) {
        self.min = min
        self.max = max
        self.error = error
    }
}

extension VGSValidationRuleLength: VGSRuleValidator {
  internal func validate(input: String?) -> Bool {

      guard let input = input else {
          return false
      }
      return input.count >= min && input.count <= max
  }
}
