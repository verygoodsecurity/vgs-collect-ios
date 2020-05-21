//
//  State.swift
//
//  Created by Vitalii Obertynskyi on 9/15/19.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// An object that describes `VGSTextField` state.  State attributes are read-only.
public class State {
    
    /// `VGSConfiguration.fieldName` associated  with `VGSTextField`
    internal(set) open var fieldName: String!
    
    /// `VGSConfiguration.isRequired` attribute defined for `VGSTextField`
    internal(set) open var isRequired: Bool = false
    
    /// `VGSConfiguration.isRequiredValidOnly` attribute defined for `VGSTextField`
    internal(set) open var isRequiredValidOnly: Bool = false
    
    /// Contains current validation state for `VGSTextField`
    internal(set) open var isValid: Bool = false
    
    /// Show if `VGSTextField` input is empty
    internal(set) open var isEmpty: Bool = false
  
    /// Input data length in `VGSTextField`
    internal(set) open var inputLength: Int = 0

    
    init(tf: VGSTextField) {
        fieldName = tf.fieldName
        isRequired = tf.isRequired
        isRequiredValidOnly = tf.isRequiredValidOnly
        isValid = tf.isValid
        isEmpty = (tf.textField.getSecureRawText?.count == 0)
        inputLength = tf.textField.getSecureRawText?.count ?? 0
    }
    
    /// Message that contains `State` attributes and their values
    public var description: String {
        var result = ""
        
        guard let fieldName = fieldName else {
            return "Alias property is empty"
        }
        
        result = """
        "\(fieldName)": {
            "isRequired": \(isRequired),
            "isRequiredValidOnly": \(isRequiredValidOnly),
            "isValid": \(isValid),
            "isEmpty": \(isEmpty),
            "inputLength": \(inputLength)
        }
        """
        return result
    }
}

/// An object that describes `VGSCardTextField` state.  State attributes are read-only.
public class CardState: State {
    
    /// Last 4 digits of the valid card number from associated `VGSTextField` with field configuration type `FieldType.cardNumber`.
    internal(set) open var last4: String = ""
    
    /// Bin digits of the valid card number from associated `VGSTextField` with field configuration type `FieldType.cardNumber`.
    internal(set) open var bin: String = ""
    
    /// Credit Card Brand of the card number from associated `VGSTextField` with field configuration type `FieldType.cardNumber`.
    internal(set) open var cardBrand: SwiftLuhn.CardType = .unknown
        
    override init(tf: VGSTextField) {
        super.init(tf: tf)
        
        guard let originalText = tf.textField.getSecureRawText else {
            return
        }
        
        self.isValid = SwiftLuhn.validateCardNumber(originalText)
        self.cardBrand = SwiftLuhn.getCardType(from: originalText)
        self.last4 = self.isValid ? String(originalText.suffix(4)) : ""
        self.bin = self.isValid ? String(originalText.prefix(6)): ""
    }
    
    /// Message that contains `CardState` attributes and their values.
    override public var description: String {
        var result = super.description
        if isValid {
            result.append("""
            , {
                "bin": \(bin),
                "last4": \(last4),
                "cardBrand": \(cardBrand),
                "cardBrandName": \(cardBrand.stringValue)
            }
            """)
        }
        return result
    }
}
