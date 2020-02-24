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
        guard let text = textField.getSecureRawText else {
            return defPattern
        }
        
        let clearText = text.components(separatedBy: " ").joined(separator: "")
        
        switch clearText.count {
        case 4...14:
            return "#### ###### ####"
            
        case 15:
            return "#### ###### #####"
            
        case 16:
            return defPattern
            
        case 17...19:
            return "#### #### #### #### ###"
            
        default:
            return defPattern
        }
    }
    
    var formatPatternForCvc: String {
        if let state = state as? CardState {
            switch state.cardBrand {
            case .amex:
                return "####"
                
            default:
                return "###"
            }
        }
        return "###"
    }
}
