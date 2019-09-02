//
//  Enums.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit

public enum FieldType: Int, CaseIterable {
    case none
    case cardNumberField
    case dateExpirationField
    case cvvField
    case nameHolderField
    
    var isSecureDate: Bool {
        switch self {
        case .cardNumberField, .cvvField:
            return true
        default:
            return false
        }
    }
    
    var keyboardType: UIKeyboardType{
        switch self {
        case .cardNumberField, .cvvField, .dateExpirationField:
            return .decimalPad
        default:
            return .alphabet
        }
    }
}

public enum ButtonType: Int, CaseIterable {
    case none
    case sendButton
    
    var defaultTitle: String {
        switch self {
        case .sendButton:
            return "Send"
        default:
            return ""
        }
    }
}
