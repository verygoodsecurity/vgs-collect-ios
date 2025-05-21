//
//  VGSTextFieldRepresentableInitializer.swift
//  VGSCollectSDK
//

import SwiftUI

@available(iOS 14.0, *)
internal struct VGSTextFieldRepresentableInitializer {
    static func configure<T: VGSTextField>(_ textField: T, representable: VGSTextFieldRepresentableProtocol) {
        textField.font = representable.font
        textField.autocorrectionType = representable.autocorrectionType
        textField.autocapitalizationType = representable.autocapitalizationType
        textField.spellCheckingType = representable.spellCheckingType
        textField.padding = representable.textFieldPadding
        textField.textAlignment = representable.textAlignment
        textField.clearButtonMode = representable.clearButtonMode
        textField.isSecureTextEntry = representable.isSecureTextEntry
        textField.adjustsFontForContentSizeCategory = representable.adjustsFontForContentSizeCategory
        textField.keyboardAccessoryView = representable.keyboardAccessoryView
        textField.textFieldAccessibilityLabel = representable.textFieldAccessibilityLabel
        if let foregroundColor = representable.foregroundColor { textField.textColor = foregroundColor }
        if let borderColor = representable.borderColor { textField.borderColor = borderColor }
        if let lineWidth = representable.bodrerWidth { textField.borderWidth = lineWidth }
        if !representable.attributedPlaceholder.isNilOrEmpty { textField.attributedPlaceholder = representable.attributedPlaceholder }
        if !representable.placeholder.isNilOrEmpty { textField.placeholder = representable.placeholder }
        representable.cardScanCoordinator?.registerTextField(textField)
    }
}
