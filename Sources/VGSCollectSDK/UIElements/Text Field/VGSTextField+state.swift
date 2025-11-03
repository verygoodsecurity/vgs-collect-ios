//
//  VGSTextField+state.swift
//  VGSCollectSDK
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
  
    /// Describes `VGSTextField` input `State`.
    ///
    /// Returned instance type varies by `fieldType`:
    /// - `.cardNumber` -> `VGSCardState` (includes `bin`, `last4`, `cardBrand`).
    /// - `.ssn` -> `VGSSSNState` (includes `last4`).
    /// - other types -> `VGSTextFieldState`.
    ///
    /// Evaluation occurs lazily when accessed; validation rules run to populate `isValid` & `validationErrors`.
    ///
    /// Usage:
    /// ```swift
    /// let state = cardField.state
    /// if state.isValid { print(state.description) }
    /// ```
    /// Avoid calling repeatedly inside performance‑critical loops; cache if needed within a single run‑loop tick.
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
