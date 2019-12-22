//
//  VGSTextField+patternFormat.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 22.12.2019.
//  Copyright © 2019 VGS. All rights reserved.
//

import Foundation

extension VGSTextField {
    var patterFormat: String {
        
        guard let state = state as? CardState else { return "#### #### #### ####" }
        
        switch state.cardBrand {
        case .amex:
            return "#### ###### #####"
            
        case .maestro:
            return "#### #### #### #### ###"
            
        case .dinersClub:
            return "#### ###### ####"
            
        default:
            return "#### #### #### ####"
        }
    }
    
    var symbolCount: ClosedRange<Int>? {
        
        guard let state = state as? CardState else { return nil }
        
        switch state.cardBrand {
        case .amex:
            return 15...15
            
        case .maestro:
            return 12...19
            
        case .dinersClub:
            return 15...15
            
        default:
            return 16...16
        }
    }
}
