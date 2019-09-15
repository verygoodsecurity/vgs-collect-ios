//
//  VGSModel.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 8/21/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

public class VGSConfiguration {
    private(set) weak var vgsForm: VGSForm?
    
    public private(set) var alias: String!
    
    public var validationModel: VGSValidation?
    public var token: String?
    public var isRequired: Bool = false
    public var placeholder: String = ""
    public var type: FieldType = .none
    public var formatPattern: String = ""
    
    public init(form vgs: VGSForm, alias: String) {
        self.vgsForm = vgs
        self.alias = alias
    }
}
