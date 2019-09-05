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
    public var placeholder: String?
    public var type: FieldType = .none
    
    public init(_ vgs: VGSForm, alias name: String, textField type: FieldType = .none, placeholder text: String = "") {
        self.vgsForm = vgs
        self.alias = name
        self.placeholder = text
        self.type = type
    }
}
