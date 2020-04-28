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

internal protocol VGSBaseConfigurationProtocol {
    
    var vgsCollector: VGSCollect? { get }
    
    var fieldName: String { get }
}

internal protocol VGSTextFieldConfigurationProtocol: VGSBaseConfigurationProtocol {

    var validationModel: VGSValidation? { get set }
    
    var isRequired: Bool { get }
    
    var isRequiredValidOnly: Bool { get }
    
    var type: FieldType { get }
    
    var formatPattern: String? { get set }
    
    var keyboardType: UIKeyboardType? { get set }
    
    var returnKeyType: UIReturnKeyType? { get set }
    
    var keyboardAppearance: UIKeyboardAppearance? { get set }
}

/// A class responsible for configuration VGSTextField.
public class VGSConfiguration: VGSTextFieldConfigurationProtocol {
    
    // MARK: - Attributes
    
    /// Collect form that will be assiciated with VGSTextField.
    private(set) weak var vgsCollector: VGSCollect?

    /// Internal Validation model.
    internal var validationModel: VGSValidation?
    
    /// Type of field congfiguration. Default is `FieldType.none`.
    public var type: FieldType = .none
    
    /// Name that will be associated with `VGSTextField` and used as a JSON key on submitting textfield data to your organozation vault.
    public let fieldName: String
    
    /// Set if `VGSTextField` is required to be non-empty and non-nil on submit. Default is `false`.
    public var isRequired: Bool = false
    
    /// Set if `VGSTextField` is required to be valid only on submit. Default is `false`.
    public var isRequiredValidOnly: Bool = false
    
    /// Input data visual format pattern. If not applied, will be  set by default depending on field `type`.
    public var formatPattern: String?
    
    /// String, used to replace not default `VGSConfiguration.formatPattern` characters in input text on submit request.
    public var devider: String?

    /// Preferred UIKeyboardType for `VGSTextField`.  If not applied, will be set by default depending on field `type` parameter.
    public var keyboardType: UIKeyboardType?
    
    ///Preferred UIReturnKeyType for `VGSTextField`.
    public var returnKeyType: UIReturnKeyType?
    
    /// Preferred UIKeyboardAppearance for textfield. By default is `UIKeyboardAppearance.default`.
    public var keyboardAppearance: UIKeyboardAppearance?
         
    // MARK: - Initialization
    
    /// Initialization
    ///
    /// - Parameters:
    ///   - vgs: `VGSCollect` instance.
    ///   - fieldName: associated `fieldName`.
    public init(collector vgs: VGSCollect, fieldName: String) {
        self.vgsCollector = vgs
        self.fieldName = fieldName
    }
}
