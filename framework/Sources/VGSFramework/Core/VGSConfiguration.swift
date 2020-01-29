//
//  VGSModel.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 8/21/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Class for configuration yout VGSTextField
public class VGSConfiguration {
    private(set) weak var vgsCollector: VGSCollect?

    /// Field name - actualy this is key for you JSON wich contains data
    public private(set) var fieldName: String!
    
    /// Validation model
    var validationModel: VGSValidation?
    
    /// Set this property if text filed is required
    public var isRequired: Bool = false
    
    /// Type of text filed. By default `none`
    public var type: FieldType = .none
    
    /// Set your patter format. Exmp: `##/##` equela `12/23`
    public var formatPattern: String = ""
    
    public var keyboardType: UIKeyboardType?
    
    public var returnKeyType: UIReturnKeyType?
        
    /// Initialization
    ///
    /// - Parameters:
    ///   - vgs: VGSForm instance
    ///   - fieldName: Name for your text field
    public init(collector vgs: VGSCollect, fieldName: String) {
        self.vgsCollector = vgs
        self.fieldName = fieldName
    }
}
