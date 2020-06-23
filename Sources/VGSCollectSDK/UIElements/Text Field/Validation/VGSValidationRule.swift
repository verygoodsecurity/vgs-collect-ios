//
//  VGSValidationRule.swift
//  VGSCollectSDK
//
//  Created by Dima on 23.06.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

public protocol VGSValidationRule {
    
    associatedtype InputType
    
    func validate(input: InputType?) -> Bool
    
    var error: VGSValidationError { get }
}

public struct VGSValidationRuleSet<InputType> {
    
    internal var rules = [AnyValidationRule<InputType>]()
    
    public init() { }
    
    public init<Rule: VGSValidationRule>(rules: [Rule]) where Rule.InputType == InputType {
        
        self.rules = rules.map(AnyValidationRule.init)
    }
    
    public mutating func add<Rule: VGSValidationRule>(rule: Rule) where Rule.InputType == InputType {
     
        let anyRule = AnyValidationRule(base: rule)
        rules.append(anyRule)
    }
}

internal struct AnyValidationRule<InputType>: VGSValidationRule {
    
    let error: VGSValidationError
    
    private let baseValidateInput: (InputType?) -> Bool
    
    init<Rule: VGSValidationRule>(base: Rule) where Rule.InputType == InputType {
        
        baseValidateInput = base.validate
        error = base.error
    }
    
    func validate(input: InputType?) -> Bool {
        
        return baseValidateInput(input)
    }
}
