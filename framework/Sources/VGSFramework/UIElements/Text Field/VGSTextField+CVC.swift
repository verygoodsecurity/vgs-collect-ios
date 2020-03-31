//
//  VGSTextField+patternFormat.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 22.12.2019.
//  Copyright © 2019 VGS. All rights reserved.
//

import Foundation

internal extension VGSTextField {
    
    static var cvcRegexForAnyCardType: String {
       return "^([0-9]{3,4})$"
    }
    
    var cvcFormatPatternForCardType: String {
        let format3 = "###"
        let format4 = "####"
        if let state = state as? CardState {
            switch state.cardBrand {
            case .amex, .unknown:
                return format4
            default:
                return format3
            }
        }
        return format4
    }
    
    var cvcRegexForCardType: String {
        let format3 = "^([0-9]{3})$"
        let format4 = "^([0-9]{4})$"
        if let state = state as? CardState {
            switch state.cardBrand {
            case .amex:
                return format4
            case .unknown:
                return Self.cvcRegexForAnyCardType
            default:
                return format3
            }
        }
        return Self.cvcRegexForAnyCardType
    }
}
