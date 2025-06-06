//
//  VGSDateTextFieldRepresentable.swift
//  VGSCollectSDK
//
import SwiftUI
import Combine

@available(iOS 14.0, *)
public struct VGSDateTextFieldRepresentable: UIViewRepresentable, VGSDateTextFieldRepresentableProtocol, VGSTextFieldRepresentableCallbacksProtocol {
  /// A class responsible for configuration VGSDateTextFieldRepresentable.
  var configuration: VGSDateConfiguration
  /// `VGSDateTextFieldRepresentable` text font.
  var font: UIFont?
  /// Placeholder string.
  var placeholder: String?
  /// Textfield attributedPlaceholder string.
  var attributedPlaceholder: NSAttributedString?
  /// Textfield autocapitalization type. Default is `.sentences`.
  var autocapitalizationType: UITextAutocapitalizationType = .sentences
  /// Determines whether autocorrection is enabled or disabled during typing.
  var autocorrectionType: UITextAutocorrectionType = .default
  /// Textfield spell checking type. Default is `UITextSpellCheckingType.default`.
  var spellCheckingType: UITextSpellCheckingType  = .default
  /// `UIEdgeInsets` for text and placeholder inside `VGSTextField`.
  var textFieldPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  /// The technique to use for aligning the text.
  var textAlignment: NSTextAlignment = .natural
  /// Sets when the clear button shows up. Default is `UITextField.ViewMode.never`
  var clearButtonMode: UITextField.ViewMode = .never
  /// Identifies whether the text object should disable text copying and in some cases hide the text being entered. Default is false.
  var isSecureTextEntry: Bool = false
  /// Indicates whether `VGSDateTextFieldRepresentable ` should automatically update its font when the device’s `UIContentSizeCategory` is changed.
  var adjustsFontForContentSizeCategory: Bool = false
  /// Input Accessory View
  var keyboardAccessoryView: UIView?
  /// Field text color.
  var foregroundColor: UIColor?
  /// Field background color.
  var backgroundColor: UIColor?
  /// Field border color.
  var borderColor: UIColor?
  /// Field border line width.
  var bodrerWidth: CGFloat?
  /// Field corner radius
  var cornerRadius: CGFloat?
  /// Coordinates connection between scan data and text field.
  var cardScanCoordinator: VGSCardScanCoordinator?
  
  // MARK: - Accessibility attributes
  /// A succinct label in a localized string that identifies the accessibility text field.
  var textFieldAccessibilityLabel: String?
  
  // MARK: - TextField interaction callbacks
  /// The state type is VGSTextFieldState.
  public typealias StateType = VGSTextFieldState
  /// `VGSTextFieldRepresentable` callback events. Return state object.
  public var onEditingEvent: ((VGSTextFieldEditingEvent<VGSTextFieldState>) -> Void)?
  public var onStateChange: ((VGSTextFieldState) -> Void)?
  /// Base TextFieldRepresentable Coordinator type
  public typealias Coordinator = VGSTextFieldRepresentableCoordinator<VGSDateTextFieldRepresentable>
  
  // MARK: - ExpDate TextField specific attributes
  /// UIPickerView Month Label format. Default is `.shortSymbols`.
  var monthPickerFormat: VGSDateTextField.MonthFormat = .shortSymbols
  
  // MARK: - Initialization
  /// Initialization
  ///
  /// - Parameters:
  ///   - configuration: `VGSConfiguration` instance.
  public init(configuration: VGSDateConfiguration) {
    self.configuration = configuration
  }
  
  public func makeCoordinator() -> Coordinator {
    return VGSTextFieldRepresentableCoordinator(self)
  }
  
  public func makeUIView(context: Context) -> VGSDateTextField {
      let vgsTextField = VGSDateTextField()
      vgsTextField.configuration = configuration
      vgsTextField.monthPickerFormat = monthPickerFormat
      /// Default config
      VGSTextFieldRepresentableInitializer.configure(vgsTextField, representable: self)
      vgsTextField.delegate = context.coordinator
      return vgsTextField
  }

  public func updateUIView(_ uiView: VGSDateTextField, context: Context) {
      context.coordinator.parent = self
      if let frgdColor = foregroundColor {uiView.textColor = frgdColor}
      if let bkgdColor = backgroundColor {uiView.backgroundColor = bkgdColor}
      if let brdColor = borderColor {uiView.borderColor = brdColor}
      if let lineWidth = bodrerWidth {uiView.borderWidth = lineWidth}
      if let crnRadius = cornerRadius {uiView.cornerRadius = crnRadius}
  }

  // MARK: - Configuration methods
  /// Set `UIFont` value.
  public func font(_ font: UIFont) -> VGSDateTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.font = font
      return newRepresentable
  }
  /// Set `placeholder` string.
  public func placeholder(_ text: String) -> VGSDateTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.placeholder = text
      return newRepresentable
  }
  /// Set `attributedPlaceholder` string.
  public func attributedPlaceholder(_ text: NSAttributedString?) -> VGSDateTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.attributedPlaceholder = text
      return newRepresentable
  }
  /// Set `UITextAutocorrectionType` type.
  public func autocorrectionType(_ type: UITextAutocorrectionType) -> VGSDateTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.autocorrectionType = type
      return newRepresentable
  }
    /// Set `UITextAutocapitalizationType` type.
  public func autocapitalizationType(_ type: UITextAutocapitalizationType) -> VGSDateTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.autocapitalizationType = type
      return newRepresentable
  }
  /// Set `UITextSpellCheckingType` type.
  public func spellCheckingType(_ type: UITextSpellCheckingType) -> VGSDateTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.spellCheckingType = type
      return newRepresentable
  }
  /// Set `UIEdgeInsets` insets.
  public func textFieldPadding(_ insets: UIEdgeInsets) -> VGSDateTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.textFieldPadding = insets
      return newRepresentable
  }
  /// Set `NSTextAlignment` type.
  public func textAlignment(_ alignment: NSTextAlignment) -> VGSDateTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.textAlignment = alignment
    return newRepresentable
  }
    /// Set `isSecureTextEntry` value.
  public func setSecureTextEntry(_ secure: Bool) -> VGSDateTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.isSecureTextEntry = secure
    return newRepresentable
  }
  /// Set `adjustsFontForContentSizeCategory` value.
  public func adjustsFontForContentSizeCategory(_ adjusts: Bool) -> VGSDateTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.adjustsFontForContentSizeCategory = adjusts
    return newRepresentable
  }
  /// Set `keyboardAccessoryView` view.
  public func keyboardAccessoryView(_ view: UIView?) -> VGSDateTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.keyboardAccessoryView = view
    return newRepresentable
  }
  /// Set `textFieldAccessibilityLabel` string.
  public func textFieldAccessibilityLabel(_ label: String) -> VGSDateTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.textFieldAccessibilityLabel = label
    return newRepresentable
  }
  /// Set `foregroundColor`.
  public func foregroundColor(_ color: UIColor) -> VGSDateTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.foregroundColor = color
      return newRepresentable
  }
    /// Set `backgroundColor`.
  public func backgroundColor(_ color: UIColor) -> VGSDateTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.backgroundColor = color
      return newRepresentable
  }
  /// Set `borderColor` and `lineWidth`.
  public func border(color: UIColor, lineWidth: CGFloat) -> VGSDateTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.borderColor = color
      newRepresentable.bodrerWidth = lineWidth
      return newRepresentable
  }
  /// Set `cornerRadius`.
  public func cornerRadius(_ cornerRadius: CGFloat) -> VGSDateTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.cornerRadius = cornerRadius
      return newRepresentable
  }
  /// Coordinates connection between scan data and text field.
  public func cardScanCoordinator(_ coordinator: VGSCardScanCoordinator) -> VGSDateTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.cardScanCoordinator = coordinator
    return newRepresentable
  }
  // MARK: - VGSDateTextField specific methods
  /// Set `VGSDateTextField.MonthFormat`  UIPicker format. Default is `.shortSymbols`.
  public func monthPickerFormat(_ format: VGSDateTextField.MonthFormat) -> VGSDateTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.monthPickerFormat = format
    return newRepresentable
  }

  // MARK: - Handle editing events
  /// Handle  TextField Representable  editing events.
  public func onEditingEvent(_ action: ((VGSTextFieldEditingEvent<StateType>) -> Void)?) -> Self {
      var newRepresentable = self
      newRepresentable.onEditingEvent = action
      return newRepresentable
  }
  /// Handle `VGSTextFieldState` changes.
  public func onStateChange(_ action: ((VGSTextFieldState) -> Void)?) -> VGSDateTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.onStateChange = action
    return newRepresentable
  }
}
