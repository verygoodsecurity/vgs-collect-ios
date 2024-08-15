//
//  VGSDateTextFieldRepresentable.swift
//  VGSCollectSDK
//
import SwiftUI
import Combine

@available(iOS 14.0, *)
public struct VGSDateTextFieldRepresentable: UIViewRepresentable, VGSDateTextFieldRepresentableProtocol, VGSTextFieldEditingRepresentableProtocol {
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
 
//    /// The natural size for the Textfield, considering only properties of the view itself.
//    override var intrinsicContentSize: CGSize
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
  /// Field border color.
  var borderColor: UIColor?
  /// Field border line width.
  var bodrerWidth: CGFloat?
  /// Coordinates connection between scan data and text field.
  var cardScanCoordinator: VGSCardScanCoordinator?
  // MARK: - Accessibility attributes
  /// A succinct label in a localized string that identifies the accessibility text field.
  var textFieldAccessibilityLabel: String?
//    /// Boolean value that determinates if the text field should be exposed as an accesibility element.
//    var textFieldIsAccessibilityElement: Bool

  // MARK: - TextField editing callbacks
  /// `VGSDateTextFieldRepresentable` did become first responder.
  public var onEditingStart: (() -> Void)?
  /// `VGSDateTextFieldRepresentable` input changed.
  public var onCharacterChange: (() -> Void)?
  /// `VGSDateTextFieldRepresentable` did resign first responder.
  public var onEditingEnd: (() -> Void)?
  /// Returns new `VGSTextFieldState` object on change.
  public var onStateChange: ((VGSTextFieldState) -> Void)?
  
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

  public func makeUIView(context: Context) -> VGSDateTextField {
      let vgsTextField = VGSDateTextField()
      vgsTextField.configuration = configuration
      vgsTextField.delegate = context.coordinator
      vgsTextField.textAlignment = textAlignment
      vgsTextField.autocorrectionType = autocorrectionType
      vgsTextField.autocapitalizationType = autocapitalizationType
      vgsTextField.spellCheckingType = spellCheckingType
      vgsTextField.padding = textFieldPadding
      vgsTextField.textAlignment = textAlignment
      vgsTextField.clearButtonMode = clearButtonMode
      vgsTextField.isSecureTextEntry = isSecureTextEntry
      vgsTextField.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
      vgsTextField.keyboardAccessoryView = keyboardAccessoryView
      vgsTextField.textFieldAccessibilityLabel = textFieldAccessibilityLabel
      vgsTextField.monthPickerFormat = monthPickerFormat
      if let color = borderColor {vgsTextField.borderColor = color}
      if let lineWidth = bodrerWidth {vgsTextField.borderWidth = lineWidth}
      if !attributedPlaceholder.isNilOrEmpty { vgsTextField.attributedPlaceholder = attributedPlaceholder }
      if !placeholder.isNilOrEmpty { vgsTextField.placeholder = placeholder}
      cardScanCoordinator?.registerTextField(vgsTextField)
      vgsTextField.statePublisher
              .receive(on: DispatchQueue.main)
              .sink { newState in
                  self.onStateChange?(newState)
              }
              .store(in: &context.coordinator.cancellables)
      return vgsTextField
  }

  public func updateUIView(_ uiView: VGSDateTextField, context: Context) {
  }

  public func makeCoordinator() -> Coordinator {
      Coordinator(self)
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
  /// Set `borderColor` and `lineWidth`.
  public func border(color: UIColor, lineWidth: CGFloat) -> VGSDateTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.borderColor = color
      newRepresentable.bodrerWidth = lineWidth
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
  /// Handle `VGSDateTextFieldRepresentable` did become first responder.
  public func onEditingStart(_ action: (() -> Void)?) -> VGSDateTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.onEditingStart = action
    return newRepresentable
  }
  /// Handle `VGSDateTextFieldRepresentable` input changed.
  public func onCharacterChange(_ action: (() -> Void)?) -> VGSDateTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.onCharacterChange = action
    return newRepresentable
  }
  /// Handle `VGSDateTextFieldRepresentable` did resign first responder.
  public func onEditingEnd(_ action: (() -> Void)?) -> VGSDateTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.onEditingEnd = action
    return newRepresentable
  }
  /// Handle `VGSTextFieldState` changes.
  public func onStateChange(_ action: ((VGSTextFieldState) -> Void)?) -> VGSDateTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.onStateChange = action
    return newRepresentable
  }
  
  public class Coordinator: NSObject, VGSTextFieldDelegate {
    var parent: VGSDateTextFieldRepresentable
    var cancellables = Set<AnyCancellable>()

    init(_ parent: VGSDateTextFieldRepresentable) {
        self.parent = parent
    }

    public func vgsTextFieldDidBeginEditing(_ textField: VGSTextField) {
      parent.onEditingStart?()
    }
    
    public func vgsTextFieldDidChange(_ textField: VGSTextField) {
      parent.onCharacterChange?()
    }
    
    public func vgsTextFieldDidEndEditing(_ textField: VGSTextField) {
      parent.onEditingEnd?()
    }
    
    public func vgsTextFieldDidEndEditingOnReturn(_ textField: VGSTextField) {
      parent.onEditingEnd?()
    }
  }
}
