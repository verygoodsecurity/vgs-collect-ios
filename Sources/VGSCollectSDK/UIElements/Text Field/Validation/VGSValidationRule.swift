//
//  VGSValidationRule.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public protocol VGSValidationRule {
  
    var error: VGSValidationError { get }
  
}

internal protocol VGSRuleValidator {
    
    func validate(input: String?) -> Bool
}

public struct VGSValidationRuleSet {
    
    internal var rules = [AnyValidationRule]()
    
    public init() { }
    
    public init(rules: [VGSValidationRule]) {
        
        self.rules = rules.map(AnyValidationRule.init)
    }
    
    public mutating func add(rule: VGSValidationRule) {
     
        let anyRule = AnyValidationRule(base: rule)
        rules.append(anyRule)
    }
}

internal struct AnyValidationRule: VGSValidationRule {
    
    let error: VGSValidationError
    
    private let baseValidateInput: ((String?) -> Bool)?

    init(base: VGSValidationRule) {
        
      baseValidateInput = (base as? VGSRuleValidator)?.validate ?? nil
      error = base.error
    }
    
    func validate(input: String?) -> Bool {
        
      return baseValidateInput?(input) ?? true
    }
}
