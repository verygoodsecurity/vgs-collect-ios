//
//  VGSValidationRuleLuhnCheck.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public struct VGSValidationRuleLuhnCheck: VGSValidationRule {
  public var error: VGSValidationError

  public init(error: VGSValidationError) {
    self.error = error
  }
  
  public func validate(input: String?) -> Bool {
    
    guard let input = input else {
      return false
    }
    return SwiftLuhn.performLuhnAlgorithm(with: input)
  }
}
