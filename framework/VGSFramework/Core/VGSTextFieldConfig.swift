//
//  VGSModel.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 8/21/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

public class VGSTextFieldConfig {
    private(set) weak var vgsForm: VGSForm?
    
    public private(set) var alias: String!
    
    public var token: String?
    public var isRequired: Bool = false
    public var placeholder: String?
    public var type: FieldType = .none
    
    public init(form vgs: VGSForm,
                alias: String,
                isRequired: Bool = false,
                textFieldType: FieldType = .none,
                placeholderText: String = "") {
        
        self.vgsForm = vgs
        self.alias = alias
        self.isRequired = isRequired
        self.placeholder = placeholderText
        self.type = textFieldType
    }
}
