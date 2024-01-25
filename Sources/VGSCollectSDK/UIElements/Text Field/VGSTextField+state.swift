//
//  VGSTextField+state.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 9/10/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#endif

/// :nodoc: Extensions for `VGSTextField.`
public extension VGSTextField {

	  /// Return current focus status.
    override var isFocused: Bool {
        return focusStatus
    }
    
    // MARK: - State
  
    /// Describes `VGSTextField` input   `State`
    var state: VGSTextFieldState {
        var result: VGSTextFieldState
        
        switch fieldType {
        case .cardNumber:
            result = VGSCardState(tf: self)
        case .ssn:
            result = VGSSSNState(tf: self)
        default:
            result = VGSTextFieldState(tf: self)
        }
        return result
    }
}

internal extension VGSTextField {
  func validate() -> [VGSValidationError] {
    let str = textField.getSecureRawText ?? ""
    return VGSValidator.validate(input: str, rules: validationRules)
  }
}
