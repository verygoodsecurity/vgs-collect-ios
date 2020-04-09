//
//  State.swift
//  Alamofire
//
//  Created by Vitalii Obertynskyi on 9/15/19.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public class State {
    private(set) open var fieldName: String!
    open var isRequired: Bool = false
    open var isRequiredValidOnly: Bool = false
    open var isValid: Bool = false
    open var isEmpty: Bool = false
    
    init(tf: VGSTextField) {
        fieldName = tf.fieldName
        isRequired = tf.isRequired
        isRequiredValidOnly = tf.isRequiredValidOnly
        isValid = tf.isValid
        isEmpty = (tf.textField.getSecureRawText?.count == 0)
    }
    
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
            "isEmpty": \(isEmpty)
        }
        """
        return result
    }
}

public class CardState: State {
    open var last4: String = ""
    open var bin: String = ""
    open var cardBrand: SwiftLuhn.CardType = .unknown
    
    override public init(tf: VGSTextField) {
        super.init(tf: tf)
        
        guard let originalText = tf.textField.getSecureRawText else {
            return
        }
        
        self.isValid = SwiftLuhn.validateCardNumber(originalText)
        self.cardBrand = SwiftLuhn.getCardType(from: originalText)
        self.last4 = self.isValid ? String(originalText.suffix(4)) : ""
        self.bin = self.isValid ? String(originalText.prefix(6)): ""
    }
    
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
