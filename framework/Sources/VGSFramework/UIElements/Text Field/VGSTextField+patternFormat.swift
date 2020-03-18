//
//  VGSTextField+patternFormat.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 22.12.2019.
//  Copyright © 2019 VGS. All rights reserved.
//

import Foundation

extension VGSTextField {
    var formatPatternForCard: String {
        let defPattern = "#### #### #### ####"
        return defPattern
// TBD: -
//        guard let text = textField.getSecureRawText else {
//            return defPattern
//        }
//
//        let clearText = text.components(separatedBy: " ").joined(separator: "")
//
//        guard let state = state as? CardState else {
//            return defPattern
//        }
//
//        let cardBrand = state.cardBrand
//
//        switch clearText.count {
//        case 4...14:
//            return "#### ###### ####"
//
//        case 15:
//            return "#### ###### #####"
//
//        case 16:
//            return defPattern
//
//        case 17...19:
//            return "#### #### #### #### ###"
//
//        default:
//            return defPattern
//        }
    }
    
    var formatPatternForCvc: String {
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
        return format3
    }
}
