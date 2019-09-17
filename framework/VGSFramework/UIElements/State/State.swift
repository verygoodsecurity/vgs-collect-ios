//
//  State.swift
//  Alamofire
//
//  Created by Vitalii Obertynskyi on 9/15/19.
//

import Foundation

public class State {
    private(set) open var alias: String!
    open var isRequired: Bool = false
    open var isValid: Bool = false
    open var isEmpty: Bool = false
    
    init(tf: VGSTextField) {
        alias = tf.alias
        isRequired = tf.isRequired
        isValid = tf.isValid
        isEmpty = (tf.text?.count == 0)
    }
    
    public var description: String {
        var result = ""
        
        guard let alias = alias else {
            return "Alias property is empty"
        }
        
        result.append("Name:\(alias)\n")
        result.append("-isRequired:\(isRequired)\n")
        result.append("-isValid:\(isValid)\n")
        result.append("-isEmpty:\(isEmpty)\n")
        
        return result
    }
}

public class CardState: State {
    open var last4: String = ""
    open var first6: String = ""
    open var cardBrand: SwiftLuhn.CardType = .unknown
    
    override public init(tf: VGSTextField) {
        super.init(tf: tf)
        
        guard let originalText = tf.text?.replacingOccurrences(of: " ", with: "") else {
            return
        }
        
        self.last4 = String(originalText.suffix(4))
        self.first6 = String(originalText.prefix(6))
        self.isValid = originalText.isValidCardNumber()
        self.cardBrand = originalText.suggestedCardType()
    }
    
    override public var description: String {
        var result = super.description
        
        if isValid {
            result.append("-last4:\(last4)\n")
            result.append("-first6:\(first6)\n")
            result.append("-cardBrand:\(cardBrand)\n")
        }
        return result
    }
}
