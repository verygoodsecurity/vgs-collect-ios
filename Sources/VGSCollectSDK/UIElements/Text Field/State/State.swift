//
//  State.swift
//
//  Created by Vitalii Obertynskyi on 9/15/19.
//

import Foundation
#if os(iOS)
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
  
    /// Show if `VGSTextField` was edited
    internal(set) open var isDirty: Bool = false
  
    /// Input data length in `VGSTextField`
    internal(set) open var inputLength: Int = 0

    /// Array of `VGSValidationError`. Should be empty when textfield input is valid.
    internal(set) open var validationErrors =  [VGSValidationError]()
    
    init(tf: VGSTextField) {
        fieldName = tf.fieldName
        isRequired = tf.isRequired
        isRequiredValidOnly = tf.isRequiredValidOnly
        validationErrors = tf.validate()
        isValid = validationErrors.count == 0
        isEmpty = (tf.textField.getSecureRawText?.count == 0)
        isDirty = tf.isDirty
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
            "validationErrors": \(validationErrors),
            "isEmpty": \(isEmpty),
            "isDirty": \(isDirty),
            "inputLength": \(inputLength)
        }
        """
        return result
    }
}

/// An object that describes `VGSTextField` state with configuration `FieldType.cardNumber` .  State attributes are read-only.
public class CardState: State {
    
    /// Last 4 digits of the valid card number from associated `VGSTextField` with field configuration type `FieldType.cardNumber`.
    internal(set) open var last4: String = ""
    
    /// Bin digits of the valid card number from associated `VGSTextField` with field configuration type `FieldType.cardNumber`.
    internal(set) open var bin: String = ""
    
    /// Credit Card Brand of the card number from associated `VGSTextField` with field configuration type `FieldType.cardNumber`.
    internal(set) open var cardBrand: VGSPaymentCards.CardBrand = .unknown
        
    override init(tf: VGSTextField) {
        super.init(tf: tf)
        
        guard let input = tf.textField.getSecureRawText else {
            return
        }
        
        self.cardBrand = VGSPaymentCards.detectCardBrandFromAvailableCards(input: input)
        if self.isValid {
          self.bin = String(input.prefix(6))
          self.last4 = (input.count) >= 12 ? String(input.suffix(4)) : ""
        }
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

/// An object that describes `VGSTextField` state with configuration `FieldType.ssn` .  State attributes are read-only.
public class SSNState: State {
    
    /// Last 4 digits of the valid ssn from associated `VGSTextField` with field configuration type `FieldType.ssn`.
    internal(set) open var last4: String = ""
    
    override init(tf: VGSTextField) {
        super.init(tf: tf)
        
        guard let originalText = tf.textField.getSecureRawText else {
            return
        }
        if self.isValid {
          self.last4 = originalText.count == 9 ? String(originalText.suffix(4)) : ""
        }
    }
  
    /// Message that contains `SSNState` attributes and their values.
    override public var description: String {
        var result = super.description
        if isValid {
            result.append("""
            , {
                "last4": \(last4)
            }
            """)
        }
        return result
    }
}
