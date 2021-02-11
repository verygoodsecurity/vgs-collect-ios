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

internal extension VGSTextField {
  func validate() -> [VGSValidationError] {
    let str = textField.getSecureRawText ?? ""
    return VGSValidator.validate(input: str, rules: validationRules)
  }
}
