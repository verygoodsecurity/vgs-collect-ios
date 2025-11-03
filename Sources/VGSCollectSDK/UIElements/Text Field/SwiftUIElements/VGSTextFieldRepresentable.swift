//
//  VGSTextFieldRepresentable.swift
//  VGSCollectSDK
//

import SwiftUI
import Combine

@available(iOS 14.0, *)
/// A SwiftUI wrapper around `VGSTextField` providing secure data collection with a declarative builder-style API.
///
/// Overview:
/// `VGSTextFieldRepresentable` lets you embed the UIKit `VGSTextField` inside SwiftUI while configuring appearance, behavior, and callbacks in a chainable, value-type friendly manner.
///
/// Features:
/// - Chainable modifiers (`font`, `placeholder`, `border`, etc.).
/// - Live state & editing event callbacks (`onEditingEvent`, `onStateChange`).
/// - Optional accessory view and secure text entry.
///
/// Security:
/// - No sensitive text is exposed through published properties; retrieval and submission handled internally.
/// - Avoid storing raw values outside SDK-managed flows.
///
/// Clearing Input:
/// - Use `clearTextTrigger(_:)` binding to programmatically clear the field from SwiftUI state.
///
/// Example:
/// ```swift
/// VGSTextFieldRepresentable(configuration: config)
///   .placeholder("Cardholder name")
///   .font(.preferredFont(forTextStyle: .body))
///   .border(color: .gray, lineWidth: 1)
///   .onStateChange { state in print(state.isValid) }
/// ```
public struct VGSTextFieldRepresentable: UIViewRepresentable, @preconcurrency VGSTextFieldRepresentableProtocol, VGSTextFieldRepresentableCallbacksProtocol {
  
    /// A class responsible for configuration VGSTextFieldRepresentable.
    var configuration: VGSConfiguration
    /// `VGSTextFieldRepresentable` text font.
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
    /// Indicates whether `VGSTextFieldRepresentable ` should automatically update its font when the device’s `UIContentSizeCategory` is changed.
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
    /// Remove text input trigger
    internal var clearTextTrigger: Binding<Bool>?
    // MARK: - Accessibility attributes
    /// A succinct label in a localized string that identifies the accessibility text field.
    var textFieldAccessibilityLabel: String?
    // MARK: - TextField interaction callbacks
    /// The state type is VGSTextFieldState.
    public typealias StateType = VGSTextFieldState
    /// `VGSTextFieldRepresentable` callback events. Return state object.
    public var onEditingEvent: ((VGSTextFieldEditingEvent<VGSTextFieldState>) -> Void)?
    /// `VGSTextFieldRepresentable` state events
    public var onStateChange: ((VGSTextFieldState) -> Void)?
    /// Base TextFieldRepresentable Coordinator type
    public typealias Coordinator = VGSTextFieldRepresentableCoordinator<VGSTextFieldRepresentable>
  
    // MARK: - Initialization
    /// Initialization
    ///
    /// - Parameters:
    ///   - configuration: `VGSConfiguration` instance.
    public init(configuration: VGSConfiguration) {
      self.configuration = configuration
    }
  
    public func makeCoordinator() -> Coordinator {
      return VGSTextFieldRepresentableCoordinator(self)
    }
  
    public func makeUIView(context: Context) -> VGSTextField {
      let vgsTextField = VGSTextField()
      vgsTextField.configuration = configuration
      /// Default config
      VGSTextFieldRepresentableInitializer.configure(vgsTextField, representable: self)
      vgsTextField.delegate = context.coordinator
      return vgsTextField
    }

  public func updateUIView(_ uiView: VGSTextField, context: Context) {
    context.coordinator.parent = self
    if let frgdColor = foregroundColor {uiView.textColor = frgdColor}
    if let bkgdColor = backgroundColor {uiView.backgroundColor = bkgdColor}
    if let brdColor = borderColor {uiView.borderColor = brdColor}
    if let lineWidth = bodrerWidth {uiView.borderWidth = lineWidth}
    if let crnRadius = cornerRadius {uiView.cornerRadius = crnRadius}
    if let binding = self.clearTextTrigger, binding.wrappedValue {
      uiView.cleanText()
      DispatchQueue.main.async {
        binding.wrappedValue = false
      }
    }
  }
  /// Removes text from input.
  /// - Parameter binding: A `Binding<Bool>` that when set to `true` triggers clearing and is reset to `false` automatically.
  public func clearTextTrigger(_ binding: Binding<Bool>) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.clearTextTrigger = binding
      return newRepresentable
  }
  // MARK: - Configuration methods
  /// Set `UIFont` value.
  public func font(_ font: UIFont) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.font = font
      return newRepresentable
  }
  /// Set `placeholder` string.
  public func placeholder(_ text: String) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.placeholder = text
      return newRepresentable
  }
  /// Set `attributedPlaceholder` string.
  public func attributedPlaceholder(_ text: NSAttributedString?) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.attributedPlaceholder = text
      return newRepresentable
  }
  /// Set `UITextAutocorrectionType` type.
  public func autocorrectionType(_ type: UITextAutocorrectionType) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.autocorrectionType = type
      return newRepresentable
  }
  /// Set `UITextAutocapitalizationType` type.
  public func autocapitalizationType(_ type: UITextAutocapitalizationType) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.autocapitalizationType = type
      return newRepresentable
  }
  /// Set `UITextSpellCheckingType` type.
  public func spellCheckingType(_ type: UITextSpellCheckingType) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.spellCheckingType = type
      return newRepresentable
  }
  /// Set `UIEdgeInsets` insets.
  public func textFieldPadding(_ insets: UIEdgeInsets) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.textFieldPadding = insets
      return newRepresentable
  }
  /// Set `NSTextAlignment` type.
  public func textAlignment(_ alignment: NSTextAlignment) -> VGSTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.textAlignment = alignment
    return newRepresentable
  }
    /// Set `isSecureTextEntry` value.
  public func setSecureTextEntry(_ secure: Bool) -> VGSTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.isSecureTextEntry = secure
    return newRepresentable
  }
  /// Set `adjustsFontForContentSizeCategory` value.
  public func adjustsFontForContentSizeCategory(_ adjusts: Bool) -> VGSTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.adjustsFontForContentSizeCategory = adjusts
    return newRepresentable
  }
  /// Set `keyboardAccessoryView` view.
  public func keyboardAccessoryView(_ view: UIView?) -> VGSTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.keyboardAccessoryView = view
    return newRepresentable
  }
  /// Set `textFieldAccessibilityLabel` string.
  public func textFieldAccessibilityLabel(_ label: String) -> VGSTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.textFieldAccessibilityLabel = label
    return newRepresentable
  }
  /// Set `foregroundColor`.
  public func foregroundColor(_ color: UIColor) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.foregroundColor = color
      return newRepresentable
  }
  /// Set `backgroundColor`.
  public func backgroundColor(_ color: UIColor) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.backgroundColor = color
      return newRepresentable
  }
  /// Set `borderColor` and `lineWidth`.
  public func border(color: UIColor, lineWidth: CGFloat) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.borderColor = color
      newRepresentable.bodrerWidth = lineWidth
      return newRepresentable
  }
  /// Set `cornerRadius`.
  public func cornerRadius(_ cornerRadius: CGFloat) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.cornerRadius = cornerRadius
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
  public func onStateChange(_ action: ((VGSTextFieldState) -> Void)?) -> VGSTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.onStateChange = action
    return newRepresentable
  }

  /// Coordinates connection between scan data and text field.
  public func cardScanCoordinator(_ coordinator: VGSCardScanCoordinator) -> VGSTextFieldRepresentable {
    var newRepresentable = self
    newRepresentable.cardScanCoordinator = coordinator
    return newRepresentable
  }
}
