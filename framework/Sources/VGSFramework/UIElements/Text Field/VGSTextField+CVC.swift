//
//  VGSTextField+patternFormat.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 22.12.2019.
//  Copyright © 2019 VGS. All rights reserved.
//

import Foundation

extension VGSTextField {
    var cvcFormatPattern: String {
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
}
