//
//  Enums.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit

public enum Environment: String {
    case sandbox = "sandbox"
    case live = "live"
}

public enum FieldType: Int, CaseIterable {
    case none
    case cardNumber
    case dateExpiration
    case cvv
    case cardHolderName
    
    var formatPattern: String {
        switch self {
        case .cardNumber:
            return "#### #### #### ####"
        case .cvv:
            return "####"
        case .dateExpiration:
            return "##/##"
        default:
            return ""
        }
    }
    
    var regex: String {
        switch self {
        case .cardNumber:
            return "^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\\d{3})\\d{11})$"
        case .cvv:
            return "^([0-9]{3,4})$"
        case .dateExpiration:
            return "^(0[1-9]|1[0-2])\\/?([0-9]{4}|[0-9]{2})$"
        default:
            return ""
        }
    }
    
    var isSecureDate: Bool {
        switch self {
        case .cvv:
            return true
        default:
            return false
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .cardNumber, .cvv, .dateExpiration:
            return .decimalPad
        default:
            return .alphabet
        }
    }
}
