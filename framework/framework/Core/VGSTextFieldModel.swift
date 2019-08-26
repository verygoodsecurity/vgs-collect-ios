//
//  VGSModel.swift
//  framework
//
//  Created by Vitalii Obertynskyi on 8/21/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

public class VGSTextFieldModel {
    private(set) var alias: String!
    
    public var token: String?
    public var placeholder: String?
    public var type: FieldType = .none
    
    
    public init(alias name: String, placeholder text: String = "", textField type: FieldType = .none) {
        self.alias = name
        self.placeholder = text
        self.type = type
    }
}
