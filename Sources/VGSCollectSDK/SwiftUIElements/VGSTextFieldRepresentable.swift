//
//  VGSTextFieldRepresentable.swift
//  VGSCollectSDK
//

import SwiftUI
import Combine

@available(iOS 14.0, *)
public struct VGSTextFieldRepresentable: UIViewRepresentable {
  
    var configuration: VGSConfiguration
    
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
    var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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

  
    // MARK: - Accessibility Attributes
    /// A succinct label in a localized string that identifies the accessibility text field.
    var textFieldAccessibilityLabel: String?
//    /// Boolean value that determinates if the text field should be exposed as an accesibility element.
//    var textFieldIsAccessibilityElement: Bool
  
    // MARK:- TextField interaction callbacks
    public var onEditingStart: (() -> Void)?
    public var onCharacterChange: (() -> Void)?
    public var onEditingEnd: (() -> Void)?
    
    /// Returns new `VGSTextFieldState` object on change.
    public var onStateChange: ((VGSTextFieldState) -> Void)?
  
    
    public init(configuration: VGSConfiguration) {
      self.configuration = configuration
    }
  
    public func makeUIView(context: Context) -> VGSTextField {
        let vgsTextField = VGSTextField()
        vgsTextField.configuration = configuration
        vgsTextField.delegate = context.coordinator
        if !attributedPlaceholder.isNilOrEmpty { vgsTextField.attributedPlaceholder = attributedPlaceholder }
        if !placeholder.isNilOrEmpty { vgsTextField.placeholder = placeholder}

        vgsTextField.textAlignment = textAlignment
      
        vgsTextField.autocorrectionType = autocorrectionType
        vgsTextField.autocapitalizationType = autocapitalizationType
        vgsTextField.spellCheckingType = spellCheckingType
        vgsTextField.padding = padding
        vgsTextField.textAlignment = textAlignment
        vgsTextField.clearButtonMode = clearButtonMode
        vgsTextField.isSecureTextEntry = isSecureTextEntry
        vgsTextField.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
        vgsTextField.keyboardAccessoryView = keyboardAccessoryView
        vgsTextField.textFieldAccessibilityLabel = textFieldAccessibilityLabel
      
        
        vgsTextField.statePublisher
                .receive(on: DispatchQueue.main)
                .sink { newState in
                    self.onStateChange?(newState)
                }
                .store(in: &context.coordinator.cancellables)
        return vgsTextField
    }

    public func updateUIView(_ uiView: VGSTextField, context: Context) {

    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
  
    // MARK: -  Configuration methods
    public func placeholder(_ text: String) -> VGSTextFieldRepresentable {
        var newRepresentable = self
        newRepresentable.placeholder = text
        return newRepresentable
    }
  
    public func attributedPlaceholder(_ text: NSAttributedString?) -> VGSTextFieldRepresentable {
        var newRepresentable = self
        newRepresentable.attributedPlaceholder = text
        return newRepresentable
    }
  
    public func autocapitalizationType(_ type: UITextAutocapitalizationType) -> VGSTextFieldRepresentable {
        var newRepresentable = self
        newRepresentable.autocapitalizationType = type
        return newRepresentable
    }
  
    public func spellCheckingType(_ type: UITextSpellCheckingType) -> VGSTextFieldRepresentable {
        var newRepresentable = self
        newRepresentable.spellCheckingType = type
        return newRepresentable
    }
  
    public func padding(_ insets: UIEdgeInsets) -> VGSTextFieldRepresentable {
        var newRepresentable = self
        newRepresentable.padding = insets
        return newRepresentable
    }
  
    public func textAlignment(_ alignment: NSTextAlignment) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.textAlignment = alignment
      return newRepresentable
    }
  
    public func setSecureTextEntry(_ secure: Bool) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.isSecureTextEntry = secure
      return newRepresentable
    }
  
    public func adjustsFontForContentSizeCategory(_ adjusts: Bool) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.adjustsFontForContentSizeCategory = adjusts
      return newRepresentable
    }
    
    public func keyboardAccessoryView(_ view: UIView?) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.keyboardAccessoryView = view
      return newRepresentable
    }
  
    public func textFieldAccessibilityLabel(_ label: String) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.textFieldAccessibilityLabel = label
      return newRepresentable
    }
  
    // MARK: - Handle editing events
  
    public func onEditingStart(_ action: (() -> Void)?) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.onEditingStart = action
      return newRepresentable
    }
  
    public func onCharacterChange(_ action: (() -> Void)?) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.onCharacterChange = action
      return newRepresentable
    }

    public func onEditingEnd(_ action: (() -> Void)?) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.onEditingEnd = action
      return newRepresentable
    }
  
    public func onStateChange(_ action: ((VGSTextFieldState) -> Void)?) -> VGSTextFieldRepresentable {
      var newRepresentable = self
      newRepresentable.onStateChange = action
      return newRepresentable
    }
    

    public class Coordinator: NSObject, VGSTextFieldDelegate {
      var parent: VGSTextFieldRepresentable
      var cancellables = Set<AnyCancellable>()

      init(_ parent: VGSTextFieldRepresentable) {
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
