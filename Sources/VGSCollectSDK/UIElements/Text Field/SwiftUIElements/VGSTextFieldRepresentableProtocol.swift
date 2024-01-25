//
//  VGSTextFieldRepresentableProtocol.swift
//  VGSCollectSDK
//

import Foundation

// MARK: - VGSCardTextFieldRepresentable.
internal protocol VGSTextFieldRepresentableProtocol {
  /// Textfiled text font.
  var font: UIFont? {get set}
  /// Placeholder string.
  var placeholder: String? {get set}
  /// Textfield attributedPlaceholder string.
  var attributedPlaceholder: NSAttributedString? {get set}
  /// Textfield autocapitalization type.
  var autocapitalizationType: UITextAutocapitalizationType {get set}
  /// Determines whether autocorrection is enabled or disabled during typing.
  var autocorrectionType: UITextAutocorrectionType {get set}
  /// Textfield spell checking type.
  var spellCheckingType: UITextSpellCheckingType {get set}
   /// `UIEdgeInsets` for text and placeholder inside `VGSTextField`.
  var textFieldPadding: UIEdgeInsets  {get set}
  /// The technique to use for aligning the text.
  var textAlignment: NSTextAlignment {get set}
  /// Sets when the clear button shows up.
  var clearButtonMode: UITextField.ViewMode {get set}
  /// Identifies whether the text object should disable text copying and in some cases hide the text being entered. Default is false.
  var isSecureTextEntry: Bool {get set}
  /// Indicates whether textfiled  should automatically update its font when the device’s `UIContentSizeCategory` is changed.
  var adjustsFontForContentSizeCategory: Bool {get set}
  /// Input Accessory View
  var keyboardAccessoryView: UIView? {get set}
  /// Field border color.
  var borderColor: UIColor? {get set}
  /// Field border line width.
  var bodrerWidth: CGFloat? {get set}

  // MARK: - Accessibility attributes
  /// A succinct label in a localized string that identifies the accessibility text field.
  var textFieldAccessibilityLabel: String? {get set}
}

/// A base set of optional methods to manage editing text in a text field object.
internal protocol VGSTextFieldDelegateRepresentableProtocol {
  /// TextField  did become first responder.
  var onEditingStart: (() -> Void)? {get set}
  /// TextField input changed.
  var onCharacterChange: (() -> Void)? {get set}
  /// TextField did resign first responder.
  var onEditingEnd: (() -> Void)? {get set}
}

/// A  set of optional methods to manage editing text and validation in a text field object.
internal protocol VGSTextFieldEditingRepresentableProtocol: VGSTextFieldDelegateRepresentableProtocol {
  /// Returns new `VGSTextFieldState` object on change.
  var onStateChange: ((VGSTextFieldState) -> Void)? {get set}
}

// MARK: - VGSCardTextFieldRepresentable.
/// A  set of optional methods to manage editing text and validation in a card  text field object.
internal protocol VGSCardTextFieldEditingRepresentableProtocol: VGSTextFieldDelegateRepresentableProtocol {
  /// Returns new `VGSTextFieldState` object on change.
  var onStateChange: ((VGSCardState) -> Void)? {get set}
}

internal protocol VGSCardTextFieldRepresentableProtocol: VGSTextFieldRepresentableProtocol {
  /// Card brand icon size.
  var cardIconSize: CGSize {get set}
  /// Card brand icon positions enum.
  var cardIconLocation: VGSCardTextField.CardIconLocation {get set}
}
// MARK: - VGSExpDateTextFieldRepresentable.
internal protocol VGSExpDateTextFieldRepresentableProtocol: VGSTextFieldRepresentableProtocol {
  /// UIPickerView Month Label format.
  var monthPickerFormat: VGSExpDateTextField.MonthFormat {get set}
  /// UIPickerView Year Label format.
  var yearPickerFormat: VGSExpDateTextField.YearFormat {get set}
}

// MARK: - VGSCVCTextFieldRepresentable.

internal protocol VGSCVCTextFieldRepresentableProtocol: VGSTextFieldRepresentableProtocol {
  /// Card brand icon size.
  var cvcIconSize: CGSize {get set}
  /// Card brand icon positions enum.
  var cvcIconLocation: VGSCVCTextField.CVCIconLocation {get set}
  /// Asks custom image for specific `VGSPaymentCards.CardBrand`.
  var cvcIconSource: ((VGSPaymentCards.CardBrand) -> UIImage?)? {get set}
}

// MARK: - VGSDateTextFieldRepresentable.
internal protocol VGSDateTextFieldRepresentableProtocol: VGSTextFieldRepresentableProtocol {
  /// UIPickerView Month Label format.
  var monthPickerFormat: VGSDateTextField.MonthFormat {get set}
}
