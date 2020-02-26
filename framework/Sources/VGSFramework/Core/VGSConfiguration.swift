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

protocol VGSBaseConfigurationProtocol {
    
    var vgsCollector: VGSCollect? { get }
    
    var fieldName: String { get }
}

protocol VGSTextFieldConfigurationProtocol: VGSBaseConfigurationProtocol {

    var validationModel: VGSValidation? { get set }
    
    var isRequired: Bool { get }
    
    var type: FieldType { get }
    
    var formatPattern: String { get set }
    
    var keyboardType: UIKeyboardType? { get set }
    
    var returnKeyType: UIReturnKeyType? { get set }
}

/// Class for configuration yout VGSTextField
public class VGSConfiguration: VGSTextFieldConfigurationProtocol {
        
    private(set) weak var vgsCollector: VGSCollect?

    /// Validation model
    internal var validationModel: VGSValidation?
    
    /// Field name - actualy this is key for you JSON wich contains data
    public let fieldName: String
    
    /// Set if text filed is required to be non-empty and non-nil on submit
    public var isRequired: Bool = false
    
    /// Set if text filed is required to be valid only on submit
    public var isRequiredValidOnly: Bool = false
    
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
