//
//  VGSTextField+state.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 9/10/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public extension VGSTextField {
    
    internal var isValid: Bool {
        let str = textField.getSecureRawText ?? ""
        return validationModel.isValid(str, type: fieldType)
    }
    
    override var isFocused: Bool {
        return focusStatus
    }
    
    /// Describes `VGSTextField` input   `State`
    var state: State {
        var result: State
        
        switch fieldType {
        case .cardNumber:
            result = CardState(tf: self)
        case .ssn:
            result = SSNState(tf: self)
        default:
            result = State(tf: self)
        }
        return result
    }
}
