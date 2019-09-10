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
            return "###"
        case .dateExpiration:
            return "##/##"
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
    
    var keyboardType: UIKeyboardType{
        switch self {
        case .cardNumber, .cvv, .dateExpiration:
            return .decimalPad
        default:
            return .alphabet
        }
    }
}
